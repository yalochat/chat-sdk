#!/bin/bash

flutter test --coverage
lcov --remove coverage/lcov.info "lib/**/*.g.dart" "lib/**/*.pb*.dart" -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

