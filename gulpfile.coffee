fs = require 'fs'
gulp = require 'gulp'
sass = require 'gulp-sass'
marked = require 'gulp-marked'
header = require 'gulp-header'
footer = require 'gulp-footer'
render = require 'gulp-handlebars-render'
map = require('map-stream')
Path = require 'path'
mime = require 'mime'

# AWS CONFIG
AWS = require 'aws-sdk'
credentials = new AWS.SharedIniFileCredentials profile: 'nst'
AWS.config.credentials = credentials;

headerText = fs.readFileSync('src/_header.html')
footerText = fs.readFileSync('src/_footer.html')
sidebarData = JSON.parse fs.readFileSync('src/metadata.json')


dist = './dist/'

bucket = 'nerd-smalltalk.com'


gulp.task 'html', ->
  gulp.src './src/html/**.md'
    .pipe marked()
    .pipe header(headerText)
    .pipe footer(footerText)
    .pipe render sidebarData
    .pipe gulp.dest(dist)

gulp.task 'css', ->
  gulp.src 'src/css/main.scss'
    .pipe sass()
    .pipe gulp.dest(dist)

gulp.task 'build', ['html', 'css']

# gulp.watch './src/html/**', ['html']
# gulp.watch '.src/css/**', ['css']

gulp.task 'deploy', ['build'], ->
  gulp.src dist + '**'
    .pipe map(toS3)

gulp.task 'default', ['build']


toS3 = (file, cb) ->
  s3 = new AWS.S3()
  mimeType = mime.lookup(file.path);
  relPath = Path.relative(file.base, file.path)
  unless relPath == ''
    s3.putObject
      Bucket: bucket
      Key: relPath
      ACL: 'public-read'
      Body: file.contents
      ContentType: mimeType
    , (err, data) ->
      if err
        console.error "Error with #{relPath}:", err
      else
        console.log "Updated #{relPath} to version #{data.VersionId}"
  cb()
