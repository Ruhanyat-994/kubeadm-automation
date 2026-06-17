/* KubeAuto Documentation — Extra JavaScript */

document.addEventListener("DOMContentLoaded", function () {
  /* Smooth anchor scrolling for in-page links */
  document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
    anchor.addEventListener("click", function (e) {
      var targetId = this.getAttribute("href").slice(1);
      var target = document.getElementById(targetId);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: "smooth", block: "start" });
        history.pushState(null, "", "#" + targetId);
      }
    });
  });
});
