console.log 'CoffeeScript from Parcel Starter!'

# How to use .env* files in code:
require('dotenv').config()
console.log "process.env.NODE_ENV (set by Parcel): #{process.env.NODE_ENV}"
console.log "process.env.SECRET (set inside .env files): #{process.env.SECRET}"

