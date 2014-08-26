###
Oraculum is distributed under the following license:
----------------------------------------------------

Copyright (c) 2014 Lookout, Inc.
https://www.lookout.com/about/contact

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---------------------------------------

Oraculum is a derivative work of Chaplin under the following copyright:
-----------------------------------------------------------------------

Copyright (C) 2012 Moviepilot GmbH
http://moviepilot.com/contact

With contributions by several individuals:
https://github.com/chaplinjs/chaplin/graphs/contributors

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
###

define [
  'Factory'
  'BackboneFactory'
], (Factory, BackboneFactory) ->
  'use strict'

  ###
  Oraculum
  ========
  Oraculum is the distillation of Chaplin's excellent behaviors broken out
  into reusable modules called _mixins_. This project is the logical extreme
  of the design factory/composer pattern exposed by FactoryJS.

  @see https://github.com/lookout/factoryjs
  ###

  # Creation
  # --------
  # Create a new Factory container for all of our mixins and definitions.
  # Pass an anonymous function that returns our base factory, BackboneFactory.
  # Finally, add 'Oraculum' as our base tag, so our definitions will inherit it.
  Oraculum = new Factory (-> BackboneFactory), baseTags: ['Oraculum']

  # Extension
  # ---------
  # Mirror all current and future definitions from BackboneFactory
  Oraculum.mirror BackboneFactory

  # Distribution
  # ------------
  # Finally, export and return the object to be used
  return window.Oraculum = Oraculum
