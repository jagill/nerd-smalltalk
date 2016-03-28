fs = require 'fs'
gulp = require 'gulp'
sass = require 'gulp-sass'
marked = require 'gulp-marked'
header = require 'gulp-header'
footer = require 'gulp-footer'
handlebars = require 'handlebars'
Path = require 'path'
mime = require 'mime'
map = require 'map-stream'
simple = require './gulp-simple-module'


# AWS CONFIG
AWS = require 'aws-sdk'
credentials = new AWS.SharedIniFileCredentials profile: 'nst'
AWS.config.credentials = credentials;

dist = './dist/'
bucket = 'nerd-smalltalk.com'

headerText = fs.readFileSync('src/_header.html')
footerText = fs.readFileSync('src/_footer.html')

metadata = JSON.parse fs.readFileSync('src/metadata.json')


gulp.task 'html', ->
  gulp.src './src/html/**.md'
    .pipe marked()
    .pipe header(headerText)
    .pipe footer(footerText)
    .pipe simple(compileHandlebars(metadata))
    .pipe gulp.dest(dist)

gulp.task 'css', ->
  gulp.src 'src/css/main.scss'
    .pipe sass()
    .pipe gulp.dest(dist)

gulp.task 'rss', ->
  gulp.src 'src/atom.xml.hbs'
    .pipe simple(compileHandlebars(metadata))
    .pipe gulp.dest(dist)

gulp.task 'assets', ->
  gulp.src 'src/assets/**'
    .pipe gulp.dest(dist + 'assets/')

gulp.task 'build', ['html', 'css', 'rss', 'assets']

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

compileHandlebars = (data) ->
  return (file) ->
    template = handlebars.compile file.contents.toString()
    file.contents = new Buffer(template(data))
    file.path = stripPathSuffix(file.path, '.hbs')
    return file

stripPathSuffix = (filepath, suffix) ->
  if Path.extname(filepath) is suffix
    filepath = filepath.slice(0, -1*suffix.length)
  return filepath
