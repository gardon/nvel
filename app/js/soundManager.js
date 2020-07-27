;(function SoundManager() {
  const sounds = {};

  clearAudios = function() {
    for (i in sounds) {
      sounds[i].fade(1,0,300);
    }
  }

  window.SoundManagerSet = function(audios) {

    clearAudios();

    for (i in audios) {
      sounds[i] = new Howl({ src: audios[i].source, loop: audios[i].stop == "" });
      if (audios[i].start == "") {
        // Start as soon as window is loaded.
        window.SoundManager(i);
      } else {
        // Trigger start when target is at least in the middle of the screen.
      }
    }
  }

  window.SoundManager = function (name) {
    const sound = sounds[name];
    console.assert(sound != null, `Unknown sound: ${name}`);
    return sound.play();
  };
}());
