This repo is mostly just a fork of: https://bitbucket.org/rkrzewski/dockerfile/src/master/protractor/ 

Dockerfile for [Protractor](http://angular.github.io/protractor/) test execution
================================================================================

This image contains a fully configured environment for running Protractor tests
under Chromium and Firefox browsers.

Installed software
------------------
   * [Xvfb](http://unixhelp.ed.ac.uk/CGI/man-cgi?Xvfb+1) The headless X server, for running browsers inside Docker
   * [node.js](http://nodejs.org/) 8.11 The runtime platform for running JavaScript on the server side, including Protractor tests
   * [npm](https://www.npmjs.com/) 5.8 Node.js package manager used to install Protractor and any specific node.js modules the tests may need
   * [Selenium webdriver](http://docs.seleniumhq.org/docs/03_webdriver.jsp) 12.0 Browser instrumentation agent used by Protractor to execute the tests
   * [Java 8 SE](http://www.oracle.com/technetwork/java/javase/) 8u162 Needed by Selenium
   * [Chromium](http://www.chromium.org/Home) 66.0 The OSS core part of Google Chrome browser
   * [Firefox](https://www.mozilla.org/en-US/firefox/desktop/) 59.0 Firefox browser
   * [Protractor](http://angular.github.io/protractor/) 5.3 An end-to-end test framework for web applications
   * [FFmpeg](https://www.ffmpeg.org/) useful for [capturing screencasts](https://www.npmjs.com/package/protractor-video-reporter) of the tests
   * [Supervisor](http://supervisord.org/) Process controll system used to manage Xvfb and Selenium background processes needed by Protractor

Running
-------
In order to run tests from a CI system, execute the following:
```
docker run --rm -v <test project location>:/project -e "PRT_CFG=tstenv-protractor.conf.js" iterativee/headless-protractor
```

or in case we just want to run default protractor.conf.js, do:

```
docker run --rm -v <test project location>:/project  iterativee/headless-protractor
```

The container will terminate automatically after the tests are completed. The output of supervisord visible on the console is not interesting in most circumstances. You should check `target/supervsor.out` file to see the output of Protractor. Dispalying the file in an Unix terminal using `cat` is recommended over opening it using an editor because the file contains ANSI escape sequences.

If you want to run the tests interactively you can launch the container and enter into it:
```
CONTAINER=$(docker run -d -v <test project location>:/project --env MANUAL=yes iterativee/headless-protractor)
docker exec -ti $CONTAINER sudo -i -u node bash
```
When inside the container you can run the tests at the console by simply invoking `protractor` or `protractor CFG_NAME`. When things don't work as expected, you should check Selenium WebDrover output in `/var/log/supervisor/webdriver-err.log`. When you are done, you terminate the Protractor container with `docker kill $CONTAINER`