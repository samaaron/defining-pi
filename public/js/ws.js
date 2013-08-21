var ws = new WebSocket('ws://' + window.location.host );

window.onload = function(){
    (function(){
        var show = function(el){
            return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; };
        }(document.getElementById('msgs'));
        ws.onopen    = function()  {  };
        ws.onclose   = function()  { show('websocket closed'); };
        ws.onmessage = function(m) { show(m.data); };
    })();
};

function sendCode() {
    ws.send('{:cmd "run-code" :val "' + editor.getValue().replace(/\"/g, '\\"') + '"}');
    return false;
}

function stopCode() {
    ws.send('{:cmd "stop" :val "' + editor.getValue().replace(/\"/g, '\\"') + '"}');
    return false;
}

function takePhoto() {
    ws.send('{:cmd "photo" :val "' + editor.getValue().replace(/\"/g, '\\"') + '"}');
    return false;
}
