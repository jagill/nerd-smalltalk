fs = require 'fs'
gulp = require 'gulp'
sass = require 'gulp-sass'
marked = require 'gulp-marked'
header = require 'gulp-header'
footer = require 'gulp-footer'
render = require 'gulp-handlebars-render'

headerText = fs.readFileSync('src/_header.html')
footerText = fs.readFileSync('src/_footer.html')
sidebarData = JSON.parse fs.readFileSync('src/metadata.json')


dest = './'


gulp.task 'html', ->
  gulp.src './src/html/**.md'
    .pipe marked()
    .pipe header(headerText)
    .pipe footer(footerText)
    .pipe render sidebarData
    .pipe gulp.dest(dest)

gulp.task 'css', ->
  gulp.src 'src/css/main.scss'
    .pipe sass()
    .pipe gulp.dest(dest)

gulp.task 'build', ['html', 'css']

# gulp.watch './src/html/**', ['html']
# gulp.watch '.src/css/**', ['css']

gulp.task 'default', ['build']
