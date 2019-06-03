images = require './img/*.png'

loadNaverMap = (data) ->
    map = new naver.maps.Map 'map', mapOptions =
        center: new naver.maps.LatLng(37.3595704, 127.105399)
        zoom: 10

    markers = []
    infoWindows = []

    for d in data
        position = new naver.maps.LatLng d.position.lat, d.position.lng

        marker = new naver.maps.Marker options =
            map: map
            position: position
            zIndex: 100

        infoContent = ''
        for detail of d.info
            infoContent += "<b>#{detail}:</b> #{d.info[detail]} <br />"

        infoWindow = new naver.maps.InfoWindow options =
            content: """
                <div style="width:150px;padding:10px;">
                    #{infoContent}
                </div>"""

        markers.push marker
        infoWindows.push infoWindow

    showMarker = (map, marker) ->
        if marker.setMap() then return
        marker.setMap(map)

    hideMarker = (map, marker) ->
        if not marker.setMap() then return
        marker.setMap(null)

    naver.maps.Event.addListener map, 'idle', () ->
        mapBounds = map.getBounds()

        for marker in markers
            position = marker.getPosition()

            if mapBounds.hasLatLng position
                showMarker map, marker
            else
                hideMarker map, marker

    # Return an event handler storing the marker index
    # as a closure variable named seq
    getClickHandler = (seq) ->
        (e) ->
            marker = markers[seq]
            infoWindow = infoWindows[seq]

            if infoWindow.getMap()
                infoWindow.close()
            else
                infoWindow.open map, marker

    for marker,index in markers
        naver.maps.Event.addListener marker, 'click', getClickHandler(index)




    onSuccessGeolocation = (position) ->
        location = new naver.maps.LatLng(position.coords.latitude,
                                         position.coords.longitude)

        map.setCenter(location)
        map.setZoom(10)

        marker = new naver.maps.Marker options =
            position: location
            map: map
            zIndex: 1000
            icon:
                content: "<img src='#{images.pin_default}' alt='' " +
                         'style="margin: 0px; padding: 0px; border: 0px solid transparent; display: block; max-width: none; max-height: none; ' +
                         '-webkit-user-select: none; position: absolute; width: 22px; height: 35px; left: 0px; top: 0px;">',
                size: new naver.maps.Size(22, 35),
                anchor: new naver.maps.Point(11, 35)

        console.log('Coordinates: ' + location.toString())

    onErrorGeolocation = ()->
        center = map.getCenter()

        infoWindow.setContent("""
            <div style="padding:20px;">
                <h5 style="margin-bottom:5px;color:#f00;">Geolocation failed!</h5>
                latitude:  #{center.lat()} <br />
                longitude: #{center.lng()}
            </div>
        """)

        infoWindow.open(map, center)

    if navigator.geolocation
        navigator.geolocation.getCurrentPosition onSuccessGeolocation, onErrorGeolocation
    else
        center = map.getCenter()
        infoWindow.setContent('''
            <div style="padding:20px;">
                <h5 style="margin-bottom:5px;color:#f00;">
                    Geolocation not supported
                </h5>
            </div>
        ''')
        infoWindow.open(map, center)

getData = () ->
    SPREADSHEET_ID = process.env.SPREADSHEET_ID
    GCP_API_KEY    = process.env.GCP_API_KEY


    url = 'https://sheets.googleapis.com/v4/spreadsheets/' +
          "#{SPREADSHEET_ID}/values/get?range=A1:ZZ999999"  +
          "&key=#{GCP_API_KEY}"

    response = await fetch url
    json = await response.json()

    results = []
    headers = null

    for value,index in json.values
        if index is 0
            [_, _, ...headers] = value
            continue

        [latLng, address, ...otherDetails] = value

        [lat, lng] = latLng.split ','

        lat = parseFloat lat
        lng = parseFloat lng

        info = {}
        for header, i in headers
            info[header] = otherDetails[i] or 'n/a'

        results.push object =
            position:
                lat: lat
                lng: lng
            info: info

    results



document.addEventListener 'DOMContentLoaded', () ->
    console.log "Starting... env version #{process.env.VERSION}"

    data = await getData()

    loadNaverMap(data)
