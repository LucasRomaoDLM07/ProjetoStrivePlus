document.addEventListener('DOMContentLoaded', function(){
  // theme toggle: dark-mode with class on body
  const btn = document.getElementById('themeToggle');
  if(btn){
    btn.addEventListener('click', function(){
      document.body.classList.toggle('dark-mode');
      btn.textContent = document.body.classList.contains('dark-mode') ? 'Light' : 'Dark';
    });
  }

  // small stagger reveal for elements with animate-in
  const items = document.querySelectorAll('.animate-in');
  items.forEach((el,i)=> el.style.animationDelay = (i*60)+'ms');
});
