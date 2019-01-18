<script>
function random_character() {
    var chars = "0123456789abcdefghijklmnopqurstuvwxyzABCDEFGHIJKLMNOPQURSTUVWXYZ";
    return chars.substr( Math.floor(Math.random() * 62), 10);
}

function refresh()
{
  alert("test");
  window.setInterval(function(){
  var imgs = document.getElementsByTagName("img");
  var date = random_character();
  for(var i=0; i< imgs.length; i++)
    { 
      var temp = imgs[i].src;

      if(temp.startsWith("/get_file"))
        {
          imgs[i].src = temp + date;
        }
    }
  },10000);
}
</script>