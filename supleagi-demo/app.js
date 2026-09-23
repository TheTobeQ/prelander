const CART_KEY = 'supleagi_cart';
const WISH_KEY = 'supleagi_wishlist';
const DISCOUNT_KEY = 'supleagi_discount';

function getCart() {
  try { return JSON.parse(localStorage.getItem(CART_KEY) || '[]'); }
  catch (_) { return []; }
}
function saveCart(cart) {
  localStorage.setItem(CART_KEY, JSON.stringify(cart));
  updateCount();
  window.dispatchEvent(new Event('cart:updated'));
}
function money(value) {
  return Number(value || 0).toFixed(2).replace('.', ',') + ' zł';
}
function getDiscount() {
  return localStorage.getItem(DISCOUNT_KEY) === 'SUPLE10' ? 0.10 : 0;
}
function addToCart(name, price, qty = 1) {
  const cart = getCart();
  const item = cart.find(i => i.name === name);
  if (item) item.qty += qty;
  else cart.push({ name, price: Number(price), qty });
  saveCart(cart);
  toast(name + ' — dodano do koszyka');
}
function addBundle() {
  const cart = getCart();
  const item = cart.find(i => i.name === 'Whey + Creatine — Zestaw');
  if (item) item.qty++;
  else cart.push({ name: 'Whey + Creatine — Zestaw', price: 179, qty: 1 });
  saveCart(cart);
  toast('Whey + Creatine — zestaw dodany');
}
function removeItem(index) {
  const cart = getCart();
  cart.splice(index, 1);
  saveCart(cart);
  renderCart();
}
function changeQty(index, delta) {
  const cart = getCart();
  if (!cart[index]) return;
  cart[index].qty += delta;
  if (cart[index].qty <= 0) cart.splice(index, 1);
  saveCart(cart);
  renderCart();
}
function updateCount() {
  const count = getCart().reduce((sum, item) => sum + Number(item.qty || 0), 0);
  document.querySelectorAll('#cartCount').forEach(el => el.textContent = count);
  let wishlist = [];
  try { wishlist = JSON.parse(localStorage.getItem(WISH_KEY) || '[]'); } catch (_) {}
  document.querySelectorAll('#wishCount').forEach(el => el.textContent = wishlist.length);
}
function toast(message) {
  const box = document.getElementById('cart');
  const text = document.getElementById('toastText');
  if (!box) return;
  if (text) text.textContent = message;
  box.classList.add('show');
  clearTimeout(window.__toastTimer);
  window.__toastTimer = setTimeout(() => box.classList.remove('show'), 2200);
}
function toggleWishlist(name) {
  let wishlist = [];
  try { wishlist = JSON.parse(localStorage.getItem(WISH_KEY) || '[]'); } catch (_) {}
  wishlist = wishlist.includes(name) ? wishlist.filter(x => x !== name) : [...wishlist, name];
  localStorage.setItem(WISH_KEY, JSON.stringify(wishlist));
  updateCount();
  toast(wishlist.includes(name) ? name + ' — dodano do ulubionych' : name + ' — usunięto z ulubionych');
}
function applyDiscount() {
  const input = document.getElementById('discountCode');
  const message = document.getElementById('discountMessage');
  if (!input || !message) return;
  const code = input.value.trim().toUpperCase();
  if (code === 'SUPLE10') {
    localStorage.setItem(DISCOUNT_KEY, code);
    message.textContent = 'Kod aktywny: −10%';
    message.className = 'discount-message success';
  } else {
    localStorage.removeItem(DISCOUNT_KEY);
    message.textContent = 'Nieprawidłowy kod. Spróbuj SUPLE10.';
    message.className = 'discount-message error';
  }
  renderCart();
}
function clearDiscount() {
  localStorage.removeItem(DISCOUNT_KEY);
  const input = document.getElementById('discountCode');
  const message = document.getElementById('discountMessage');
  if (input) input.value = '';
  if (message) message.textContent = '';
  renderCart();
}
function renderCart() {
  updateCount();
  const box = document.getElementById('cartItems');
  const cart = getCart();
  if (!box) return;
  if (!cart.length) {
    box.innerHTML = '<div class="cart-empty"><div class="eyebrow">Twój koszyk</div><h3>Jeszcze nic tu nie ma.</h3><p class="muted">Dodaj pierwszy produkt i wróć tutaj.</p><a class="btn primary" href="shop.html">Przejdź do sklepu →</a></div>';
    ['subtotal','discountAmount','shipping','total'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = '0,00 zł';
    });
    const bar = document.getElementById('freeShipBar');
    const msg = document.getElementById('freeShipText');
    if (bar) bar.style.width = '0%';
    if (msg) msg.textContent = 'Brakuje Ci 199,00 zł do darmowej dostawy 🚚';
    return;
  }

  box.innerHTML = cart.map((item, index) => {
    const line = item.price * item.qty;
    return '<div class="cart-row">' +
      '<div class="cart-product"><div class="cart-thumb">SA</div><div><b>' + item.name + '</b><div class="muted">' + money(item.price) + ' / szt.</div></div></div>' +
      '<div class="cart-controls"><div class="qty"><button aria-label="Zmniejsz" onclick="changeQty(' + index + ',-1)">−</button><b>' + item.qty + '</b><button aria-label="Zwiększ" onclick="changeQty(' + index + ',1)">+</button></div><b>' + money(line) + '</b><button class="remove" onclick="removeItem(' + index + ')">Usuń</button></div>' +
      '</div>';
  }).join('');

  const subtotal = cart.reduce((sum, item) => sum + item.price * item.qty, 0);
  const discountRate = getDiscount();
  const discount = subtotal * discountRate;
  const afterDiscount = subtotal - discount;
  const freeShipping = 199;
  const shipping = afterDiscount >= freeShipping ? 0 : 14.99;
  const total = afterDiscount + shipping;

  const set = (id, value) => { const el = document.getElementById(id); if (el) el.textContent = value; };
  set('subtotal', money(subtotal));
  set('discountAmount', discountRate ? '− ' + money(discount) : '0,00 zł');
  set('shipping', shipping ? money(shipping) : 'GRATIS');
  set('total', money(total));

  const missing = Math.max(0, freeShipping - afterDiscount);
  const bar = document.getElementById('freeShipBar');
  const msg = document.getElementById('freeShipText');
  if (bar) bar.style.width = Math.min(100, afterDiscount / freeShipping * 100) + '%';
  if (msg) msg.textContent = missing ? 'Brakuje Ci ' + money(missing) + ' do darmowej dostawy 🚚' : 'Darmowa dostawa została odblokowana 🚚';

  const discountMessage = document.getElementById('discountMessage');
  if (discountMessage && discountRate) {
    discountMessage.textContent = 'Kod SUPLE10 aktywny: −10%';
    discountMessage.className = 'discount-message success';
  }
}
function renderCheckout() {
  updateCount();
  const cart = getCart();
  const box = document.getElementById('checkoutItems');
  if (box) box.innerHTML = cart.map(item => '<div class="sumrow"><span>' + item.name + ' × ' + item.qty + '</span><b>' + money(item.price * item.qty) + '</b></div>').join('');
  const subtotal = cart.reduce((sum, item) => sum + item.price * item.qty, 0);
  const total = subtotal * (1 - getDiscount()) + (subtotal * (1 - getDiscount()) >= 199 ? 0 : 14.99);
  const el = document.getElementById('checkoutTotal');
  if (el) el.textContent = money(total);
}
function placeOrder(event) {
  event.preventDefault();
  localStorage.removeItem(CART_KEY);
  localStorage.removeItem(DISCOUNT_KEY);
  document.body.innerHTML = '<main class="wrap" style="padding-top:120px;text-align:center"><div class="eyebrow">Sukces</div><h1 style="font-size:70px;letter-spacing:-4px">Zamówienie<br><em>przyjęte.</em></h1><p class="muted">To demo — płatność nie została pobrana.</p><a class="btn primary" href="index.html">Wróć na stronę główną</a></main>';
}
function filterProducts(category, button) {
  document.querySelectorAll('.filter').forEach(el => el.classList.remove('active'));
  if (button) button.classList.add('active');
  document.querySelectorAll('.product-item').forEach(el => {
    el.style.display = category === 'all' || el.dataset.cat === category ? '' : 'none';
  });
}
const searchProducts = [
  ['Whey Protein',129],['Creatine',69],['Daily Vitamins',49],
  ['Pre-Workout',89],['Omega 3',59],['Magnez',39]
];
function openSearch() {
  const overlay = document.getElementById('searchOverlay');
  if (!overlay) return;
  overlay.classList.add('open');
  setTimeout(() => document.getElementById('searchInput')?.focus(), 50);
}
function closeSearch() { document.getElementById('searchOverlay')?.classList.remove('open'); }
function searchHome() {
  const query = (document.getElementById('searchInput')?.value || '').toLowerCase();
  const box = document.getElementById('searchResults');
  if (!box) return;
  const matches = searchProducts.filter(p => p[0].toLowerCase().includes(query));
  box.innerHTML = matches.map(p => '<div class="search-result"><span><b>' + p[0] + '</b><br><small>' + money(p[1]) + '</small></span><button onclick="addToCart(\'' + p[0] + '\',' + p[1] + ')">Dodaj</button></div>').join('') || '<p class="muted">Brak wyników.</p>';
}
updateCount();
