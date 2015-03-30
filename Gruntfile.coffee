module.exports = (grunt) ->
  
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    clean: 
      build: ["build"]
      dist: ["dist"]
      test: ["coverage"]
      shrinkwrap: 
        src: ["npm-shrinkwrap.json"]

    concat:
      options:
        separator: ";"
        
      mywallet:
        src: [
          'bower_components/jquery/dist/jquery.js'
          'bower_components/browserdetection/src/browser-detection.js'
          'src/shared.js'
          'src/ie.js'
          'src/crypto-util-legacy.js'
          'build/browserify.js'
          'build/sjcl.js'
          'build/blockchain-api.processed.js'
          'build/blockchain-settings-api.processed.js'
          'build/signer.processed.js'
          'build/wallet-store.processed.js'
          'build/wallet.processed.js'
          'build/wallet-signup.processed.js'
          'build/hd-account.processed.js'
          'build/hd-wallet.processed.js'
          'build/bip39.js'
          'build/xregexp-all.js'
          'build/bower_components/cryptojslib/rollups/sha256.js'
          'build/bower_components/cryptojslib/rollups/aes.js'
          'build/bower_components/cryptojslib/rollups/pbkdf2.js'
          'build/bower_components/cryptojslib/components/cipher-core.js'
          'build/bower_components/cryptojslib/components/pad-iso10126.js'
          'build/bower_components/cryptojslib/components/mode-ecb.js'
          'build/bower_components/cryptojslib/components/pad-nopadding.js'
        ]
        dest: "dist/my-wallet.js"
        
    uglify:
      options:
        banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
        mangle: false
        
      mywallet:
        src:  "dist/my-wallet.js"
        dest: "dist/my-wallet.min.js"

    browserify:
      options:
        debug: true
        browserifyOptions: { standalone: "Browserify" }

      build:
        src: ['src/browserify-imports.js']
        dest: 'build/browserify.js'

      production:
        options:
          debug: false
        src: '<%= browserify.dev.src %>'
        dest: 'build/browserify.js'

    karma:
      unit:
        configFile: 'karma.conf.js'
        background: true
        singleRun: false

      test:
        configFile: 'karma.conf.js'


    watch:
      scripts:
        files: [
          'src/ie.js'
          'src/shared.js'
          'src/blockchain-api.js'
          'src/blockchain-settings-api.js'
          'src/signer.js'
          'src/wallet.js'
          'src/wallet-signup.js'
          'src/hd-wallet.js'
          'src/hd-account.js'
          'src/import-export.js'
          'src/wallet-store.js'
        ]
        tasks: ['build']

      karma:
        files: ['<%= watch.scripts.files %>', 'tests/**/*.js.coffee', 'tests/**/*.js']
        tasks: ['karma:unit:run']
        
    shell: 
      check_dependencies: 
        command: () -> 
           'mkdir -p build && ruby check-dependencies.rb'
        
      npm_install_dependencies:
        command: () ->
           'cd build && npm install'
           
      bower_install_dependencies:
        command: () ->
           'cd build && bower install'

    shrinkwrap: {}
    
    env: 
      build: 
        DEBUG: "1"
        
      production:
        PRODUCTION: "1"

    preprocess:     
      multifile:
        files: 
          'build/blockchain-api.processed.js'  : 'src/blockchain-api.js'
          'build/blockchain-settings-api.processed.js'  : 'src/blockchain-settings-api.js'
          'build/signer.processed.js'         : 'src/signer.js'
          'build/wallet-store.processed.js'   : 'src/wallet-store.js'
          'build/wallet.processed.js'         : 'src/wallet.js'
          'build/wallet-signup.processed.js'  : 'src/wallet-signup.js'
          'build/hd-wallet.processed.js'      : 'src/hd-wallet.js'
          'build/hd-account.processed.js'     : 'src/hd-account.js'

  
  # Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-preprocess'
  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-shrinkwrap'

  grunt.registerTask "default", [
    "karma:unit:start"
    "watch"
  ]
  
  # The build task could do some things that are currently in npm postinstall
  grunt.registerTask "build", [
    "env:build"
    # "clean" # Too aggresive
    "preprocess"
    "browserify:build"
    "concat:mywallet"
  ]
    
  # GITHUB_USER=... GITHUB_PASSWORD=... grunt dist
  grunt.registerTask "dist", [
    "env:production"
    "clean:build"
    "clean:dist"
    "shrinkwrap"
    "shell:check_dependencies"
    "clean:shrinkwrap"
    "shell:npm_install_dependencies"
    "shell:bower_install_dependencies"
    "preprocess"
    "browserify:production"
    "concat:mywallet"
    "uglify:mywallet"
  ]
  
  return
