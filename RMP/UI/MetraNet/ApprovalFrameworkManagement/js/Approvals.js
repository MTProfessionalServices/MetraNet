
function customDetailsRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return value;
}

function customCommentRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return value;
}

function customModifiedItemDisplayNameRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return value;
}
