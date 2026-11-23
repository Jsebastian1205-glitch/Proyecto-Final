/**
 * "Mis comparaciones": guardar un duelo del Comparador y volver a verlo
 * desde Mi cuenta. Es exclusivo de los planes de pago (mensual o anual) y
 * del administrador; el backend responde 403 con el plan Gratuito o sin plan.
 *
 * Solo se guardan los dos productos (ids de la base de datos). El ganador se
 * calcula al mostrarlos, con los precios y puntajes actuales del catálogo.
 */

let dueloActual = null;          // { a, b } productos del duelo en pantalla
let ultimoDueloGuardado = null;  // clave "idA-idB" del último duelo guardado
let comparacionesCache = [];

function claveDuelo(a, b) {
  return [a.idProducto, b.idProducto].sort((x, y) => x - y).join('-');
}

// ── Botón "Guardar comparación" del Comparador ──

/** Lo llama renderDuel (script.js) cada vez que cambia el duelo. */
function actualizarGuardarDuelo(productoA, productoB) {
  const barra = document.getElementById('duel-guardar');
  const boton = document.getElementById('duel-guardar-btn');
  if (!barra || !boton) return;

  // Solo los productos que vienen de la base de datos tienen idProducto.
  const valido = productoA && productoB && productoA.idProducto && productoB.idProducto;
  dueloActual = valido ? { a: productoA, b: productoB } : null;
  barra.hidden = !valido;
  document.getElementById('duel-aviso-plan').hidden = true;
  if (!valido) return;

  const yaGuardado = ultimoDueloGuardado === claveDuelo(productoA, productoB);
  boton.disabled = yaGuardado;
  boton.textContent = yaGuardado ? '✓ Comparación guardada' : 'Guardar comparación';
}

async function manejarGuardarDuelo() {
  if (!dueloActual) return;
  if (!(window.estaAutenticado && window.estaAutenticado())) {
    mostrarError('Inicia sesión para guardar tus comparaciones.');
    toggleLogin(true);
    return;
  }

  const boton = document.getElementById('duel-guardar-btn');
  const { a, b } = dueloActual;
  boton.disabled = true;
  boton.textContent = 'Guardando…';
  try {
    await guardarComparacion(a.idProducto, b.idProducto);
    ultimoDueloGuardado = claveDuelo(a, b);
    boton.textContent = '✓ Comparación guardada';
    mostrarExito('Comparación guardada. La encuentras en Mi cuenta → Mis comparaciones.');
  } catch (err) {
    boton.disabled = false;
    boton.textContent = 'Guardar comparación';
    if (err.status === 403) {
      document.getElementById('duel-aviso-plan').hidden = false;
    } else {
      mostrarError(err.message);
    }
  }
}

// ── Pestaña "Mis comparaciones" de Mi cuenta ──

function formatearFechaComparacion(valor) {
  const fecha = new Date(valor);
  if (Number.isNaN(fecha.getTime())) return '';
  return fecha.toLocaleDateString('es-CO', { day: 'numeric', month: 'long', year: 'numeric' });
}

/** Producto del catálogo cargado con ese id de la base (o undefined). */
function productoDelCatalogo(idProducto) {
  return typeof PRODUCTS !== 'undefined' ? PRODUCTS.find((p) => p.idProducto === idProducto) : undefined;
}

function tarjetaComparacion(c) {
  const [datosA, datosB] = c.productos;
  if (!datosA || !datosB) return '';
  const a = productoDelCatalogo(datosA.idProducto);
  const b = productoDelCatalogo(datosB.idProducto);
  const puedeVerse = a && b && a.stats && b.stats;

  // Ganador con los puntajes de hoy (si el catálogo los tiene)
  let ganadorId = null;
  if (puedeVerse && typeof analyzeDuel === 'function') {
    ganadorId = analyzeDuel(a, b).winnerIsA ? datosA.idProducto : datosB.idProducto;
  }
  const lado = (d) => `
    <div class="comp-producto${ganadorId === d.idProducto ? ' es-ganador' : ''}">
      <span class="comp-marca">${escaparHtml(d.marca)}</span>
      <span class="comp-nombre">${escaparHtml(d.nombre)}</span>
      ${ganadorId === d.idProducto ? '<span class="comp-gana">Gana hoy</span>' : ''}
    </div>`;

  return `
    <article class="comp-card">
      <div class="comp-top">
        <span class="comp-categoria">${escaparHtml(datosA.categoria)}</span>
        <span class="comp-fecha">${escaparHtml(formatearFechaComparacion(c.fechaCreacion))}</span>
      </div>
      <div class="comp-duelo">
        ${lado(datosA)}
        <span class="comp-vs">VS</span>
        ${lado(datosB)}
      </div>
      <div class="comp-acciones">
        <button class="btn btn-primary" type="button" data-ver-comparacion="${c.idComparacion}"
          ${puedeVerse ? '' : 'disabled title="Uno de los productos no está disponible en el catálogo"'}>Ver de nuevo</button>
        <button class="btn-mini btn-mini-danger" type="button" data-eliminar-comparacion="${c.idComparacion}">Eliminar</button>
      </div>
    </article>`;
}

function renderizarComparaciones() {
  const lista = document.getElementById('comparaciones-lista');
  if (!lista) return;
  if (comparacionesCache.length === 0) {
    lista.innerHTML = `
      <div class="comp-vacio">
        <p>Todavía no has guardado comparaciones.</p>
        <p>En el Comparador, elige dos productos y pulsa <b>Guardar comparación</b>.</p>
        <button class="btn btn-primary" type="button" onclick="showPage('comparador')">Ir al Comparador</button>
      </div>`;
    return;
  }
  lista.innerHTML = comparacionesCache.map(tarjetaComparacion).join('');
}

function renderizarComparacionesBloqueadas() {
  const lista = document.getElementById('comparaciones-lista');
  if (!lista) return;
  lista.innerHTML = `
    <div class="comp-vacio comp-bloqueado">
      <div class="comp-candado" aria-hidden="true">🔒</div>
      <h3>Exclusivo de los planes Premium</h3>
      <p>Con un plan mensual o anual puedes guardar tus duelos del Comparador y volver a verlos cuando quieras.</p>
      <button class="btn btn-primary" type="button" onclick="showPage('planes')">Ver planes</button>
    </div>`;
}

async function cargarMisComparaciones() {
  const lista = document.getElementById('comparaciones-lista');
  if (!lista) return;
  lista.innerHTML = '<div class="plans-empty">Cargando tus comparaciones…</div>';
  try {
    comparacionesCache = await listarMisComparaciones();
    renderizarComparaciones();
  } catch (err) {
    if (err.status === 403) {
      comparacionesCache = [];
      renderizarComparacionesBloqueadas();
    } else {
      lista.innerHTML = `<div class="plans-empty">No se pudieron cargar tus comparaciones: ${escaparHtml(err.message)}</div>`;
    }
  }
}

async function manejarClicComparaciones(event) {
  const ver = event.target.closest('[data-ver-comparacion]');
  if (ver) {
    const c = comparacionesCache.find((x) => x.idComparacion === Number(ver.dataset.verComparacion));
    // Ya está guardada: el botón del Comparador aparece como "guardada".
    if (c) ultimoDueloGuardado = c.productos.map((p) => p.idProducto).sort((x, y) => x - y).join('-');
    if (!c || !window.cargarDueloGuardado(c.productos[0].idProducto, c.productos[1].idProducto)) {
      mostrarError('Uno de los productos ya no está disponible en el catálogo.');
    }
    return;
  }
  const eliminar = event.target.closest('[data-eliminar-comparacion]');
  if (eliminar) {
    const id = Number(eliminar.dataset.eliminarComparacion);
    if (!confirm('¿Eliminar esta comparación guardada?')) return;
    try {
      await eliminarComparacion(id);
      comparacionesCache = comparacionesCache.filter((c) => c.idComparacion !== id);
      ultimoDueloGuardado = null;
      renderizarComparaciones();
      mostrarExito('Comparación eliminada.');
    } catch (err) {
      mostrarError(err.message);
    }
  }
}

function inicializarComparaciones() {
  const boton = document.getElementById('duel-guardar-btn');
  if (boton) boton.addEventListener('click', manejarGuardarDuelo);
  const lista = document.getElementById('comparaciones-lista');
  if (lista) lista.addEventListener('click', manejarClicComparaciones);
}

window.actualizarGuardarDuelo = actualizarGuardarDuelo;
window.cargarMisComparaciones = cargarMisComparaciones;
window.inicializarComparaciones = inicializarComparaciones;
