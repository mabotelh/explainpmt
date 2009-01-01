function choose_username(){
	$('reset_password_use_email').hide();
	$('user_email').value = '';
	$('reset_password_use_username').show();
	$('reset_password_submit').show();
}

function choose_email(){
	$('reset_password_use_username').hide();
	$('user_username').value = '';
	$('reset_password_use_email').show();
	$('reset_password_submit').show();
}

function resetValue(el,text){
  if(el.value == text){
    el.value='';
    el.title=text;
  }
  else if(el.value == ''){
    el.value=text;
  }
  else{
    el.title=text;
  }
}

function take_action(t) {
  href = t.value.split('?')[0];
  query_string = t.value.slice(t.value.indexOf('?')+1);
  t.selectedIndex = 0; // deselect current selected option
  pairs = [];
  query_string.split('&').each(function(pair){
    t = pair.split('=');
    pairs[t[0]] = t[1];
  });
  if (pairs['confirm'] && !confirm(eval("'"+pairs['confirm']+"'"))) { return false; }
  new Ajax.Request(href, {asynchronous:true, evalScripts:true, method:pairs['method']});
  return false;
}

function showPopup() {
  if (typeof(arguments[0])!='string') arguments[0] = arguments[0].innerHTML.replace(/id="([^"]+)"/,'id="popup_$1"')
    if (arguments.length == 1) var arguments = [arguments[0], FULLHTML, STICKY, MODAL, MIDX, 0, MIDY, 0, CLOSECLICK];
  overlib.apply(null, arguments);
  overdivPopup = $('overDiv').down('div');
  if(overdivPopup.down('form')){
    Form.focusFirstElement(overdivPopup.down('form'));
  }
}

function sortAllocation(){
  var st = new SortableTable(document.getElementById("allocation"), ["CaseInsensitiveString", "Number"]);
  MaintainSort(st);
}

function sortAudits(){
  var st = new SortableTable(document.getElementById("story_audit"), ["Date", "None", "None", "CaseInsensitiveString"]);
  MaintainSort(st);
}

function move(fbox, tbox) {
  fbox = document.getElementById(fbox);
  tbox = document.getElementById(tbox);
  var arrFbox = new Array();
  var arrTbox = new Array();
  var arrLookup = new Array();
  var i;
  for (i = 0; i < tbox.options.length; i++) {
    arrLookup[tbox.options[i].text] = tbox.options[i].value;
    arrTbox[i] = tbox.options[i].text;
  }
  var fLength = 0;
  var tLength = arrTbox.length;
  for(i = 0; i < fbox.options.length; i++) {
    arrLookup[fbox.options[i].text] = fbox.options[i].value;
    if (fbox.options[i].selected && fbox.options[i].value != "") {
      arrTbox[tLength] = fbox.options[i].text;
      tLength++;
    }
    else {
      arrFbox[fLength] = fbox.options[i].text;
      fLength++;
    }
  }
  arrFbox.sort();
  arrTbox.sort();
  fbox.length = 0;
  tbox.length = 0;
  var c;
  for(c = 0; c < arrFbox.length; c++) {
    var no = new Option();
    no.value = arrLookup[arrFbox[c]];
    no.text = arrFbox[c];
    fbox[c] = no;
  }
  for(c = 0; c < arrTbox.length; c++) {
    var no = new Option();
    no.value = arrLookup[arrTbox[c]];
    no.text = arrTbox[c];
    tbox[c] = no;
  }
}

function select_all(sbox) {
  sbox = document.getElementById(sbox);
  for(i=0;i<sbox.options.length;i++) {
    sbox.options[i].selected = true;
  }
}


// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
///Javascript for maintaining scroll




window.onload = function()
{   var strCook = document.cookie;
  if(strCook.indexOf("!~")!=0)
    {
      var intS = strCook.indexOf("!~");
      var intE = strCook.indexOf("~!");
      var strPos = strCook.substring(intS+2,intE);
      window.scrollTo(0,strPos);
    }
  }
  /// Function to set Scroll position of page before postback.
  function SetScrollPosition()
  {
    var scrollYPos;
    if (typeof window.pageYOffset != 'undefined') {
      scrollYPos = window.pageYOffset;
    }
    else if (document.compatMode && document.compatMode != 'BackCompat') {
      scrollYPos = document.documentElement.scrollTop;
    }
    else {
      scrollYPos = document.body.scrollTop;
    }
    if (typeof scrollYPos != 'undefined') {
      document.cookie = "yPos=!~" + scrollYPos + "~!";
    }
  }
  /// Attaching   SetScrollPosition() function to window.onscroll event.
  window.onscroll = SetScrollPosition;
  /////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  function getCookie(NameOfCookie)
  { if (document.cookie.length > 0)
    { begin = document.cookie.indexOf(NameOfCookie+"=");
      if (begin != -1)
        { begin += NameOfCookie.length+1;
          end = document.cookie.indexOf(";", begin);
          if (end == -1) end = document.cookie.length;
          return unescape(document.cookie.substring(begin, end)); }
      }
      return null;
    }

    function setCookie(NameOfCookie, value, expiredays)
    { var ExpireDate = new Date ();
      ExpireDate.setTime(ExpireDate.getTime() + (expiredays * 24 * 3600 * 1000));
      document.cookie = NameOfCookie + "=" + escape(value) +
      ((expiredays == null) ? "" : "; expires=" + ExpireDate.toGMTString());
    }

    function delCookie (NameOfCookie)
    { if (getCookie(NameOfCookie)) {
      document.cookie = NameOfCookie + "=" +
      "; expires=Thu, 01-Jan-70 00:00:01 GMT";
    }

  }

  function MaintainSort(sortableTable1){
    sort=getCookie('exPlainPMTSort' + sortableTable1.name);
    desc=getCookie('exPlainPMTSortDirection' + sortableTable1.name);
    test = desc == "false" ? false : true
    if (sort!=null){
      sortableTable1.sort(sort, test)
    }else{
    sortableTable1.onsort();
  }
}

Ajax.InPlaceEditorWithEmptyText = Class.create(Ajax.InPlaceEditor, {

  initialize : function($super, element, url, options) {

    if (!options.emptyText)        options.emptyText      = "click to edit…";
    if (!options.emptyClassName)   options.emptyClassName = "inplaceeditor-empty";

    $super(element, url, options);

    this.checkEmpty();
  },

  checkEmpty : function() {

    if (this.element.innerHTML.length == 0 && this.options.emptyText) {

      this.element.appendChild(
          new Element("span", { className : this.options.emptyClassName }).update(this.options.emptyText)
        );
    }

  },

  getText : function($super) {

    if (empty_span = this.element.select("." + this.options.emptyClassName).first()) {
      empty_span.remove();
    }

    return $super();

  },

  onComplete : function($super, transport) {

    this.checkEmpty();
    return $super(transport);

  }

});