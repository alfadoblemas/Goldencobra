CKEDITOR.editorConfig = function(config) {
  //config.extraPlugins = 'wordcount';
  //config.wordcount = {
    // Whether or not you want to show the Word Count
    //showWordCount: false,

    // Whether or not you want to show the Char Count
    //showCharCount: true,

    // Option to limit the characters in the Editor
    //charLimit: 'unlimited',

    // Option to limit the words in the Editor
    //wordLimit: 'unlimited'
  //};

  config.toolbar_mini =
  [
    ['Maximize','-','Cut','Copy','Paste','SpellChecker','-','Scayt','-','Undo','Redo','-','Replace'],
    ['-','Link','Unlink'],
    '/',
    ['Format'],['Bold','Italic','-','Subscript','Superscript','-','Table','NumberedList','BulletedList','-','Outdent','Indent','Blockquote', 'HorizontalRule']
  ];
  config.toolbar = 'mini';
};
