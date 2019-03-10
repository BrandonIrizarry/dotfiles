
local buffer = buffer
local property, property_int = buffer.property, buffer.property_int

-- Normal colors.
property['color.black'] = 0x000000
property['color.red'] = 0x000080
property['color.green'] = 0x008000
property['color.yellow'] = 0x008080
--property['color.yellow'] = 0x00FFFF
property['color.blue'] = 0x800000
property['color.magenta'] = 0x800080
property['color.cyan'] = 0x808000
property['color.white'] = 0xC0C0C0
property['color.grey'] = 0x888888
property['color.full_white'] = 0xFFFFFF
property['color.full_blue'] = 0xFF0000
property['color.full_magenta'] = 0xFF00FF
property['color.full_yellow'] = 0x00FFFF
property['color.full_green'] = 0x00FF00

-- Extra colors.
property['color.papaya_whip'] = 0xD5EFFF

-- Default font.
property['font'], property['fontsize'] = 'Bitstream Vera Sans Mono', 10
if WIN32 then
  property['font'] = 'Courier New'
elseif OSX then
  property['font'], property['fontsize'] = 'Monaco', 12
end

-- Predefined styles.
property['style.default'] = 'font:$(font),size:$(fontsize),'..
                            'fore:$(color.white),back:$(color.black)'
property['style.linenumber'] = 'fore:$(color.magenta),back:$(color.black)'
--property['style.controlchar'] =
property['style.indentguide'] = 'fore:$(color.white)'
property['style.calltip'] = 'fore:$(color.white),back:$(color.black)'
property['style.folddisplaytext'] = 'fore:$(color.white)'

-- Token styles.
property['style.class'] = 'fore:$(color.yellow)'
property['style.comment'] = 'fore:$(color.grey)'
property['style.constant'] = 'fore:$(color.full_green)'
property['style.embedded'] = '$(style.keyword),back:$(color.black)'
property['style.error'] = 'fore:$(color.red),bold'
property['style.function'] = 'fore:$(color.full_blue)'
property['style.identifier'] = 'fore:$(color.white)'
property['style.keyword'] = 'fore:$(color.full_white)'
property['style.label'] = 'fore:$(color.red),bold'
property['style.number'] = 'fore:$(color.cyan)'
property['style.operator'] = 'fore:$(color.yellow)'
property['style.preprocessor'] = 'fore:$(color.magenta)'
property['style.regex'] = 'fore:$(color.green),bold'
property['style.string'] = 'fore:$(color.green)'
property['style.type'] = 'fore:$(color.full_yellow)'
property['style.variable'] = 'fore:$(color.blue),bold'
property['style.whitespace'] = ''


-- Multiple Selection and Virtual Space
--buffer.additional_sel_alpha =
--buffer.additional_sel_fore =
--buffer.additional_sel_back =
--buffer.additional_caret_fore =

-- Caret and Selection Styles.
buffer.caret_style = buffer.CARETSTYLE_BLOCK
buffer.caret_period = 0

buffer:set_sel_fore(true, property_int['color.white'])
buffer:set_sel_back(true, property_int['color.blue'])
--buffer.sel_alpha =
buffer.caret_fore = property_int['color.white']
buffer.caret_line_back = property_int['color.black']
--buffer.caret_line_back_alpha =

-- Fold Margin.
buffer:set_fold_margin_colour(true, property_int['color.black'])
buffer:set_fold_margin_hi_colour(true, property_int['color.black'])

-- Markers.
local MARK_BOOKMARK = textadept.bookmarks.MARK_BOOKMARK
--buffer.marker_fore[MARK_BOOKMARK] = property_int['color.black']
buffer.marker_back[MARK_BOOKMARK] = property_int['color.blue']
--buffer.marker_fore[textadept.run.MARK_WARNING] = property_int['color.black']
buffer.marker_back[textadept.run.MARK_WARNING] = property_int['color.yellow']
--buffer.marker_fore[textadept.run.MARK_ERROR] = property_int['color.black']
buffer.marker_back[textadept.run.MARK_ERROR] = property_int['color.red']
for i = 25, 31 do -- fold margin markers
  buffer.marker_fore[i] = property_int['color.black']
  buffer.marker_back[i] = property_int['color.white']
  buffer.marker_back_selected[i] = property_int['color.magenta']
end

-- Indicators.
buffer.indic_fore[ui.find.INDIC_FIND] = property_int['color.yellow']
buffer.indic_alpha[ui.find.INDIC_FIND] = 255
local INDIC_BRACEMATCH = textadept.editing.INDIC_BRACEMATCH
buffer.indic_fore[INDIC_BRACEMATCH] = property_int['color.white']
local INDIC_HIGHLIGHT = textadept.editing.INDIC_HIGHLIGHT
buffer.indic_fore[INDIC_HIGHLIGHT] = property_int['color.yellow']
buffer.indic_alpha[INDIC_HIGHLIGHT] = 255
local INDIC_PLACEHOLDER = textadept.snippets.INDIC_PLACEHOLDER
buffer.indic_fore[INDIC_PLACEHOLDER] = property_int['color.magenta']
buffer.indic_style[INDIC_PLACEHOLDER] = buffer.INDIC_STRAIGHTBOX
buffer.indic_alpha[INDIC_PLACEHOLDER] = 100
buffer.indic_outline_alpha[INDIC_PLACEHOLDER] = 255

-- Call tips.
--buffer.call_tip_fore_hlt = property_int['color.light_blue']

-- Long Lines.
buffer.edge_mode = buffer.EDGE_LINE
buffer.edge_colour = property_int['color.white']
buffer.edge_column = 80
