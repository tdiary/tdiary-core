// http://www.din.or.jp/~hagi3/JavaScript/JSTips/Mozilla/
// _dom : kind of DOM.
//        IE4 = 1, IE5+ = 2, NN4 = 3, NN6+ = 4, others = 0
_dom = document.all?(document.getElementById?2:1)
                   :(document.getElementById?4
                   :(document.layers?3:0));
var _calendar3_popElement = null;
var _calendar3_popCount = 0;

if (document.compatMode){
  if (_dom==2 && document.compatMode=="CSS1Compat") _dom = 2.5;
} // Win IE6

function getLeft(div){
  result = 0;
  while (1){
    div = div.offsetParent;
    result += div.offsetLeft;
    if (div.tagName=="BODY") return result;
  }
}

function getTop(div){
  result = 0;
  while (1){
    div = div.offsetParent;
    result += div.offsetTop;
    if (div.tagName=="BODY") return result;
  }
}

function moveDivTo(div,left,top){
  if(_dom==4){
    div.style.left=left+'px';
    div.style.top =top +'px';
    return;
  }
  if(_dom==2.5 || _dom==2 || _dom==1){
    div.style.pixelLeft=left;
    div.style.pixelTop =top;
    return;
  }
  if(_dom==3){
    div.moveTo(left,top);
    return;
  }
}

function moveDivBy(div,left,top){
  if(_dom==4){
    div.style.left=div.offsetLeft+left;
    div.style.top =div.offsetTop +top;
    return;
  }
  if(_dom==2.5 || _dom==2){
    div.style.pixelLeft=div.offsetLeft+left;
    div.style.pixelTop =div.offsetTop +top;
    return;
  }
  if(_dom==1){
    div.style.pixelLeft+=left;
    div.style.pixelTop +=top;
    return;
  }
  if(_dom==3){
    div.moveBy(left,top);
    return;
  }
}

function getDivLeft(div){
  if(_dom==2.5) return div.offsetLeft+getLeft(div);
  if(_dom==4 || _dom==2) return div.offsetLeft;
  if(_dom==1)            return div.style.pixelLeft;
  if(_dom==3)            return div.left;
  return 0;
}

function getDivTop(div){
  if(_dom==2.5) return div.offsetTop+getTop(div);
  if(_dom==4 || _dom==2) return div.offsetTop;
  if(_dom==1)            return div.style.pixelTop;
  if(_dom==3)            return div.top;
  return 0;
}

function getDivWidth (div){
  if(_dom==4 || _dom==2.5 || _dom==2) return div.offsetWidth;
  if(_dom==1)            return div.style.pixelWidth;
  if(_dom==3)            return div.clip.width;
  return 0;
}

function getDivHeight(div){
  if(_dom==4 || _dom==2.5 || _dom==2) return div.offsetHeight;
  if(_dom==1)            return div.style.pixelHeight;
  if(_dom==3)            return div.clip.height;
  return 0;
}

function popup(target,element,notitle) {
  _calendar3_popCount++;
  popdownNow();
  if (navigator.appName=='Microsoft Internet Explorer') {
    moveDivTo(element,getDivLeft(target)+getDivWidth(target),getDivTop(target)+getDivHeight(target)*13/8);
  } else {
    moveDivTo(element,getDivLeft(target)+getDivWidth(target)/2,getDivTop(target)+(getDivHeight(target)*2)/3);
  }
  element.style.display="block";
  notitle.title="";
}

function popdown(element) {
  _calendar3_popElement=element;
  setTimeout('popdownDelay()', 2000);
}

function popdownDelay() {
  _calendar3_popCount--;
  if (_calendar3_popCount==0) {
    popdownNow();
  }
}

function popdownNow() {
  if (_calendar3_popElement!=null) {
    _calendar3_popElement.style.display="none";
    _calendar3_popElement=null;
  }
}
