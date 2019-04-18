// footage button filters

function filter(ele) {
  toggleFootage(ele.id);
  toggleButtons(ele.id);
};

function toggleButtons(selection) {
  var btns = document.getElementsByClassName("btn-filter");
  for (var i = 0; i < btns.length; i++) {
    var btn = btns[i];
    if (btn.id == selection) {
      btn.classList.remove("btn-secondary");
      btn.classList.add("btn-primary");
    } else {
      btn.classList.remove("btn-primary");
      btn.classList.add("btn-secondary");
    }
  }
};

function toggleFootage(selection) {
  var allVideos = document.getElementsByClassName("video");
  for (var i = 0; i < allVideos.length; i++) {
    var video = allVideos[i].classList;
    if (video.contains(selection)) {
      // in case it was previously hidden from another filter
      video.remove("video-hidden")
    } else {
      video.add("video-hidden")
    }
  }
};
