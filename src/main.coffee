map = new naver.maps.Map 'map', mapOptions = 
    center: new naver.maps.LatLng(37.3595704, 127.105399)
    zoom: 5

infoWindow = new naver.maps.InfoWindow()


onSuccessGeolocation = (position) ->
    location = new naver.maps.LatLng(position.coords.latitude,
                                     position.coords.longitude)

    map.setCenter(location)
    map.setZoom(10)

    infoWindow.setContent('''
        <div style="padding:20px;">
            geolocation.getCurrentPosition() 위치
        </div>
    ''')
    infoWindow.open(map, location)

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


document.addEventListener 'DOMContentLoaded', () ->
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

