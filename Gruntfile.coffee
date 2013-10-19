"use strict"
LIVERELOAD_PORT = 35729
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)

mountFolder = (connect, dir) ->
    connect.static require("path").resolve(dir)

module.exports = (grunt) ->
    require("matchdep").filterDev("grunt-*").forEach(grunt.loadNpmTasks)
    modRewrite = require("connect-modrewrite")

    grunt.initConfig
        pkg: "<json:package.json>"

        # templateタスクでテンプレートを結合するための変数定義
        templates:
            head: "app/template/head.tmpl"
            slide: "app/template/slide.tmpl"
            footer: "app/template/footer.tmpl"

        # tmplファイル定義からテンプレートを結合してHTMLを生成するタスク定義
        template:
            files:
                "app/template/index.tmpl": "dist/index.html"

        # JSライブラリの依存解決を行うBOWERのタスク定義
        bower:
            dir: "app/js/vendor"
            indent: "    "

        # CoffeeScriptのコンパイルタスク定義
        coffee:
            dist:
                expand: true,
                cwd: "app/coffee"
                src: ["*.coffee"]
                dest: ".tmp/js/"
                ext: ".js"
            test:
                expand: true,
                cwd: "test/coffee"
                src: ["*.coffee"]
                dest: "test/spec/"
                ext: ".js"

        # JavaScriptのminify/難読化のタスク定義
        uglify:
            main:
                options:
                    # "preserveComments": "some"
                    banner: grunt.file.read "app/js/license.txt"
                files:
                    "dist/js/frontdev.min.js": ["dist/js/frontdev.js"]

        # CoffeeScriptのコーディングスタイルチェックのlintタスク定義
        coffeelint:
            dist: ["app/coffee/**/*.coffee"]
            test: ["test/coffee/**/*.coffee"]
            gruntfile: ["Gruntfile.coffee"]
            options: # コーディングスタイル定義
                "no_trailing_whitespace":
                    "level": "error"
                "max_line_length":
                    "level": "ignore"
                "indentation":
                    "value": 4
                    "level": "error"
                "line_endings":
                    "value": "unix"
                    "level": "error"

        # JavaScript Test Runner Karma(Testacular)のタスク定義
        karma:
            unit:
                configFile: "karma.conf.js"
                singleRun: true

        # LESS -> CSSコンパイルのタスク定義
        less:
            server:
                options:
                    paths: ["app/less"]

                files:
                    "dist/css/style.css": "app/less/style.less"

            dist:
                options:
                    paths: ["app/less"]
                    yuicompress: true # do minify

                files:
                    "dist/css/style.min.css": "app/less/style.less"

        # js, css, 画像ファイルなどの古いファイルがキャッシュから使われ続けないようにrevision管理するタスク定義
        rev:
            options:
                encoding: "utf8"
                algorithm: "md5"
                length: 8
            dist:
                files:
                    src: [
                        "dist/js/*.js"
                        "dist/js/vendor/jquery/*.js"
                        "dist/js/vendor/impress.js/js/*.js"
                        "dist/css/**/*.css"
                        "dist/img/**/*.{png,jpg,jpeg,gif,svg,webp}"
                        "dist/font/**/*"
                    ]

        # usemin, imageminタスクの準備タスク定義
        useminPrepare:
            html: "dist/index.html"
            options:
                dest: "dist"

        # minifyされたファイルを読み込むようにHTML/CSSコードを置き換えるタスク定義
        usemin:
            html: "dist/index.html"
            css: "dist/css/{,*/}*.css"
            options:
                dirs: ["dist"]

        # 画像ファイルを最適化しサイズを圧縮するタスク定義
        imagemin:
            dist:
                files: [{
                    expand: true
                    cwd: "app/img"
                    src: "*.{png,jpg,jpeg,gif,svg,webp}"
                    dest: "dist/img"
                }]

        # CSSファイルをHTTP GETリクエスト削減のため最適化するタスク定義
        cssmin:
            compress:
                files:
                    "dist/css/impress.min.css": [
                        "dist/css/impress.css"
                        # ...css
                    ]

        # ローカルサーバーを起動するタスク定義
        connect:
            options:
                port: 3501

            livereload:
                options:
                    middleware: (connect, options) ->
                        return [
                            lrSnippet
                            modRewrite [ # URL rewriteルール定義
                                "^/$ /index.html"
                            ]
                            mountFolder connect, "dist"
                        ]

        # ブラウザを起動し、ページを開くタスク定義
        open:
            server:
                url: "http://localhost:<%= connect.options.port %>"

        # 一時ファイルなどを削除するタスク定義
        clean:
            dist: [".tmp", "dist"]
            test: [".tmp"]

        # PhantomJSヘッドレスブラウザによる単体テストを実行するタスク定義
        mocha:
            all:
                src: ["test/index.html"]
                options:
                    run: true
                    reporter: "Nyan"

        # ファイル変更監視タスク定義
        # 各カテゴリのfilesの変更を検知するとtasksのタスクを順次実行する
        watch:
            options:
                nospawn: true

            template:
                files: ["app/template/*.tmpl"]
                tasks: [
                    "template"
                    "copy"
                ]
                options:
                    livereload: LIVERELOAD_PORT

            coffee:
                files: [
                    "app/coffee/*.coffee"
                ]
                tasks: [
                    "coffeelint:dist"
                    "coffee:dist"
                    "coffee:test"
                    "mocha"
                    "concat"
                    "copy"
                ]
                options:
                    livereload: LIVERELOAD_PORT

            coffeeTest:
                files: ["test/coffee/*.coffee"]
                tasks: [
                    "coffeelint:test"
                    "coffee:test"
                    "mocha"
                ]

            coffeelint:
                files: [
                    "Gruntfile.coffee"
                ]
                tasks: [
                    "coffeelint:gruntfile"
                ]

            less:
                files: ["app/less/*.less"]
                tasks: [
                    "less:server"
                    "copy"
                ]
                options:
                    livereload: LIVERELOAD_PORT

        # JavaScriptファイルの結合タスク定義
        # <script src= 記述によるHTTP GETリクエストを最小数に抑える
        concat:
            main:
                src: [
                    ".tmp/js/*.js"
                ]
                dest: "dist/js/frontdev.js"
                separator: ";"

        # サーバーから返されるファイルの容量を削減するための圧縮タスク定義
        compress:
            vendor:
                options:
                    mode: "gzip"
                expand: true
                cwd: "app/js/"
                src: ["**/*"]
                dest: "dist/js/"
                filter: (filepath) ->
                    return !(/\.(md|eot|ttf|woff|otf|png|jpg|jpeg|gif|svg|webp)$/ig.test filepath)

            main:
                options:
                    mode: "gzip"
                expand: true
                cwd: "dist/"
                src: ["**/*"]
                dest: "dist/"
                filter: (filepath) ->
                    return !(/js\/vendor\/|\.(eot|ttf|woff|otf|png|jpg|jpeg|gif|svg|webp)$/ig.test filepath)

        # デプロイ環境用(app/, public_html/)に必要ファイルを配置するコピータスク定義
        copy:
            prepare:
                files: [
                    {dest: "dist/js/", cwd: "app/js/", src: ["**"], expand: true}
                    {dest: "dist/css/", cwd: "app/css/", src: ["**"], expand: true}
                    {dest: "dist/font/", cwd: "app/font/", src: ["**"], expand: true}
                    {dest: "dist/img/", cwd: "app/img/", src: ["**"], expand: true}
                ]

            # dist:
            #     files: [
            #         {dest: "../../public_html/css/", cwd: "dist/css/", src: ["**"], expand: true}
            #         {dest: "../../public_html/img/", cwd: "dist/img/", src: ["**"], expand: true}
            #         {dest: "../../public_html/js/", cwd: "dist/js/", src: ["**"], expand: true}
            #         {dest: "../../public_html/font/", cwd: "dist/font/", src: ["**"], expand: true}
            #         {dest: "../../public_html/", cwd: "dist/", src: [
            #             "*.txt"
            #             "apple-touch-*"
            #             "favicon.ico"
            #             "*.appcache"
            #         ], expand: true}
            #         {dest: "../../app/templates/pc/", cwd: "dist/", src: [
            #             "app.html*"
            #             "404.html*"
            #             "fallback.html*"
            #         ], expand: true}
            #     ]

        concurrent:
            server: [
                "coffee:dist"
                "less:server"
                "template"
            ]
            test: [
                "coffee"
            ]
            dist: [
                "coffee:dist"
                "less:dist"
                "imagemin"
                "template"
            ]

    # タスク名, [依存タスク]定義
    # grunt serverコマンドによりbuild, livereload-start, …が実行される
    grunt.registerTask "server", (target) ->
        return grunt.task.run(["default", "connect:livereload", "open:server"]) if target is "dist"

        grunt.task.run [
            "clean"
            "copy:prepare"
            "concurrent:server"
            "concat"
            # "copy:dist"
            "connect:livereload"
            "open:server"
            "watch"
        ]

    grunt.registerTask "test", [
        "clean:test"
        "coffeelint:test"
        "concurrent:test"
        "mocha"
    ]

    # gruntコマンド(オプションなし)実行時のタスク定義
    grunt.registerTask "default", [
        "coffeelint:dist"
        "test"
        "clean"
        "copy:prepare"
        "useminPrepare"
        "concurrent:dist"
        "cssmin"
        "concat"
        "uglify"
        "rev"
        "usemin"
        "compress"
        # "copy:dist"
    ]

    # templateタスク定義(独自定義タスク)
    grunt.registerTask "template", "Generate html depending on configuration", ->
        conf = grunt.config("template")
        files = conf.files
        Object.keys(files).forEach (file) ->
            tmpl = grunt.file.read(file)
            grunt.file.write files[file], grunt.template.process(tmpl)
