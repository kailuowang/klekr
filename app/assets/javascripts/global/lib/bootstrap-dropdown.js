/* ============================================================
 * bootstrap-dropdown.js v1.3.0
 * http://twitter.github.com/bootstrap/javascript.html#dropdown
 * ============================================================
 * Copyright 2011 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function( $ ){

  var d = '.dropdown-menu'

  function clearMenus() {
    $(d).addClass('hidden')
  }

  $(function () {
    $('html').bind("click", clearMenus)
    $('body').dropdown( '.dropdown-toggle[data-dropdown]' )
  })

  /* DROPDOWN PLUGIN DEFINITION
   * ========================== */

  $.fn.dropdown = function ( selector ) {
    return this.each(function () {
      $(this).delegate(selector || d, 'click', function (e) {
        var menu = $(this).parent().find(d)
          , isActive = !menu.hasClass('hidden')

        clearMenus()
        !isActive && menu.toggleClass('hidden')
        return false
      })
    })
  }

}( window.jQuery || window.ender );