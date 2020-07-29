;(function SoundManager() {
  const sounds = {};

  clearAudios = function(fade = 0, name = null) {
    for (i in sounds) {
      if (!name || name != i) {
        sounds[i].fade(1,0,fade);
      }
    }
  }

  window.SoundManagerSet = function(audios) {

    clearAudios();

    for (i in audios) {
      sounds[i] = new Howl({ src: audios[i].source, loop: audios[i].stop == "" });
      if (audios[i].start == "") {
        // Start as soon as window is loaded.
        window.SoundManager(i, 900);
      } else {
        // Trigger start when target is at least in the middle of the screen.
        window.addEventListener('scroll', function () {
          var scroll = window.pageYOffset || document.body.scrollTop;
          var play = document.getElementById(audios[i].start).offsetTop <= scroll + (window.innerHeight / 2) && document.getElementById(audios[i].start).offsetTop > scroll;
          this.console.log(play);
          if (play) {
            if (!sounds[i].playing()) {
              window.SoundManager(i, audios[i].crossfade);
            }
          } else if (sounds[i].playing()) {
            //sounds[i].fade(1, 0, 900);
          }
        });
      }
    }
  }

  window.SoundManager = function (name, fade) {
    const sound = sounds[name];
    console.assert(sound != null, `Unknown sound: ${name}`);
    clearAudios(fade, name);
    return sound.fade(0,1, fade).play();
  };
}());
