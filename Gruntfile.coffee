module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Updating the package manifest files
    noflo_manifest:
      update:
        files:
          'component.json': ['graphs/*', 'components/*']
          'package.json': ['graphs/*', 'components/*']

    # Browser build of NoFlo
    noflo_browser:
      build:
        files:
          'browser/noflo-ajax.js': ['component.json']

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # Automated recompilation and testing when developing
    watch:
      files: ['spec/*.coffee', 'components/*.coffee']
      tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'

    # Run a server for the tests so we can actually do AJAX
    connect:
      test:
        options:
          port: 9000

    # BDD tests on browser
    mocha_phantomjs:
      options:
        output: 'spec/result.xml'
        reporter: 'spec'
      all:
        options:
          urls: ['http://localhost:9000/spec/runner.html']

    # Coding standards
    coffeelint:
      components:
        files:
          src: ['components/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-noflo-manifest'
  @loadNpmTasks 'grunt-noflo-browser'
  @loadNpmTasks 'grunt-contrib-coffee'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-contrib-watch'
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-coffeelint'

  # Our local tasks
  @registerTask 'build', 'Build NoFlo for the chosen target platform', (target = 'all') =>
    @task.run 'noflo_manifest'
    if target is 'all' or target is 'browser'
      @task.run 'noflo_browser'

  @registerTask 'test', 'Build NoFlo and run automated tests', (target = 'all') =>
    @task.run 'coffeelint'
    @task.run 'build'
    if target is 'all' or target is 'nodejs'
      # Currently no tests for node.js
      # @task.run 'cafemocha'
      null
    if target is 'all' or target is 'browser'
      @task.run 'coffee'
      @task.run 'connect'
      @task.run 'mocha_phantomjs'

  @registerTask 'default', ['test']
