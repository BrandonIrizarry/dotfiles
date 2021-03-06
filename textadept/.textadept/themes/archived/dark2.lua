-- Copyright 2007-2019 Mitchell mitchell.att.foicica.com. See LICENSE.
-- Dark theme for Textadept.
-- Contributions by Ana Balan.

local buffer = buffer
local property, property_int = buffer.property, buffer.property_int

-- Normal colors.
property['color.term_black'] = 0x000000
property['color.term_red'] = 0x000080
property['color.term_green'] = 0x008000
property['color.term_yellow'] = 0x008080
property['color.term_blue'] = 0x800000
property['color.term_magenta'] = 0x800080
property['color.term_cyan'] = 0x808000
property['color.term_white'] = 0xC0C0C0

-- Light colors. (16 color terminals only.)
-- These only apply to 16 color terminals. For other terminals, set the
-- style's `bold` attribute to use the light color variant.
property['color.term_light_black'] = 0x404040
property['color.term_light_red'] = 0x0000FF
property['color.term_light_green'] = 0x00FF00
property['color.term_light_yellow'] = 0x00FFFF
property['color.term_light_blue'] = 0xFF0000
property['color.term_light_magenta'] = 0xFF00FF
property['color.term_light_cyan'] = 0xFFFF00
property['color.term_light_white'] = 0xFFFFFF

-- Greyscale colors.
property['color.dark_black'] = 0x000000
property['color.black'] = 0x1A1A1A
property['color.light_black'] = 0x333333
property['color.grey_black'] = 0x4D4D4D
property['color.dark_grey'] = 0x666666
property['color.grey'] = 0x808080
property['color.light_grey'] = 0x999999
property['color.grey_white'] = 0xB3B3B3
property['color.dark_white'] = 0xCCCCCC
property['color.white'] = 0xE6E6E6
property['color.light_white'] = 0xFFFFFF

-- Dark colors.
property['color.dark_red'] = 0x1A1A66
property['color.dark_yellow'] = 0x1A6666
property['color.dark_green'] = 0x1A661A
property['color.dark_teal'] = 0x66661A
property['color.dark_purple'] = 0x661A66
property['color.dark_orange'] = 0x1A66B3
property['color.dark_pink'] = 0x6666B3
property['color.dark_lavender'] = 0xB36666
property['color.dark_blue'] = 0xB3661A

-- Normal colors.
property['color.red'] = 0x4D4D99
property['color.yellow'] = 0x4D9999
property['color.green'] = 0x4D994D
property['color.teal'] = 0x99994D
property['color.purple'] = 0x994D99
property['color.orange'] = 0x4D99E6
property['color.pink'] = 0x9999E6
property['color.lavender'] = 0xE69999
property['color.blue'] = 0xE6994D

-- Light colors.
property['color.light_red'] = 0x8080CC
property['color.light_yellow'] = 0x80CCCC
property['color.light_green'] = 0x80CC80
property['color.light_teal'] = 0xCCCC80
property['color.light_purple'] = 0xCC80CC
property['color.light_orange'] = 0x80CCFF
property['color.light_pink'] = 0xCCCCFF
property['color.light_lavender'] = 0xFFCCCC
property['color.light_blue'] = 0xFFCC80

-- Default font.
property['font'], property['fontsize'] = 'Bitstream Vera Sans Mono', 15
if WIN32 then
  property['font'] = 'Courier New'
elseif OSX then
  property['font'], property['fontsize'] = 'Monaco', 12
end

-- Predefined styles.
property['style.default'] = 'font:$(font),size:$(fontsize),'..
                            'fore:$(color.light_grey),back:$(color.term_black)'
property['style.linenumber'] = 'fore:$(color.dark_grey),back:$(color.black)'
--property['style.controlchar'] =
property['style.indentguide'] = 'fore:$(color.light_black)'
property['style.calltip'] = 'fore:$(color.light_grey),back:$(color.light_black)'
property['style.folddisplaytext'] = 'fore:$(color.dark_grey)'

-- Token styles.
property['style.class'] = 'fore:$(color.light_yellow)'
property['style.comment'] = 'fore:$(color.term_cyan)'
property['style.constant'] = 'fore:$(color.term_light_green)'
property['style.embedded'] = '$(style.keyword),back:$(color.term_light_black)'
property['style.error'] = 'fore:$(color.term_red),italics'
property['style.function'] = 'fore:$(color.term_light_blue)'
property['style.identifier'] = 'fore:$(color.term_white)'
property['style.keyword'] = 'fore:$(color.term_yellow)'
property['style.label'] = 'fore:$(color.term_light_yellow)'
property['style.number'] = 'fore:$(color.term_magenta)'
property['style.operator'] = 'fore:$(color.term_green)'
property['style.preprocessor'] = 'fore:$(color.term_magenta)'
property['style.regex'] = 'fore:$(color.term_light_green)'
property['style.string'] = 'fore:$(color.term_red)'
property['style.type'] = 'fore:$(color.term_light_cyan)'
property['style.variable'] = 'fore:$(color.light_blue)'
property['style.whitespace'] = ''

-- Multiple Selection and Virtual Space
--buffer.additional_sel_alpha =
--buffer.additional_sel_fore =
--buffer.additional_sel_back =
--buffer.additional_caret_fore =

-- Caret and Selection Styles.
buffer:set_sel_fore(true, property_int['color.light_black'])
buffer:set_sel_back(true, property_int['color.grey'])
--buffer.sel_alpha =
buffer.caret_fore = property_int['color.grey']
buffer.caret_line_back = property_int['color.light_black']
--buffer.caret_line_back_alpha =

-- Fold Margin.
buffer:set_fold_margin_colour(true, property_int['color.black'])
buffer:set_fold_margin_hi_colour(true, property_int['color.black'])

-- Markers.
local MARK_BOOKMARK = textadept.bookmarks.MARK_BOOKMARK
--buffer.marker_fore[MARK_BOOKMARK] = property_int['color.black']
buffer.marker_back[MARK_BOOKMARK] = property_int['color.dark_blue']
--buffer.marker_fore[textadept.run.MARK_WARNING] = property_int['color.black']
buffer.marker_back[textadept.run.MARK_WARNING] = property_int['color.yellow']
--buffer.marker_fore[textadept.run.MARK_ERROR] = property_int['color.black']
buffer.marker_back[textadept.run.MARK_ERROR] = property_int['color.red']
for i = 25, 31 do -- fold margin markers
  buffer.marker_fore[i] = property_int['color.black']
  buffer.marker_back[i] = property_int['color.dark_grey']
  buffer.marker_back_selected[i] = property_int['color.light_grey']
end

-- Indicators.
buffer.indic_fore[ui.find.INDIC_FIND] = property_int['color.dark_yellow']
buffer.indic_alpha[ui.find.INDIC_FIND] = 255
local INDIC_BRACEMATCH = textadept.editing.INDIC_BRACEMATCH
buffer.indic_fore[INDIC_BRACEMATCH] = property_int['color.light_grey']
local INDIC_HIGHLIGHT = textadept.editing.INDIC_HIGHLIGHT
buffer.indic_fore[INDIC_HIGHLIGHT] = property_int['color.orange']
buffer.indic_alpha[INDIC_HIGHLIGHT] = 255
local INDIC_PLACEHOLDER = textadept.snippets.INDIC_PLACEHOLDER
buffer.indic_fore[INDIC_PLACEHOLDER] = property_int['color.grey']

-- Call tips.
--buffer.call_tip_fore_hlt = property_int['color.light_blue']

-- Long Lines.
buffer.edge_colour = property_int['color.dark_grey']
