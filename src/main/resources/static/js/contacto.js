/**
 * Formulario de contacto (página Contacto) y pestaña "Mensajes" del panel
 * de administración.
 *
 * - Enviar un mensaje es público: POST /api/contacto. Si hay sesión, el
 *   nombre y el correo se llenan solos y el backend guarda la cuenta.
 * - Ver, marcar y eliminar mensajes es solo para ADMIN.
 * - BuildZone no envía correos automáticos: "Responder por correo" abre el
 *   programa de correo del administrador (enlace mailto:).
 */

const LARGO_MAXIMO_MENSAJE = 1000;
const LARGO_MINIMO_MENSAJE = 10;

const ESTADOS_MENSAJE = {
  NUEVO: { texto: 'Nuevo', badge: 'badge-purple' },
  LEIDO: { texto: 'Leído', badge: 'badge-gris' },
  RESPONDIDO: { texto: 'Respondido', badge: 'badge-verde' },
};

let mensajesCache = [];
let filtroMensajes = 'todos';
let mensajeAbierto = null;

// ── Formulario público ──

function actualizarContadorContacto() {
  const area = document.getElementById('contacto-mensaje');
  const contador = document.getElementById('contacto-contador');
  if (!area || !contador) return;
  const largo = area.value.length;
  contador.textContent = `${largo} / ${LARGO_MAXIMO_MENSAJE}`;
  contador.classList.toggle('cerca', largo > LARGO_MAXIMO_MENSAJE * 0.9);
}

/** Al abrir la página: si hay sesión, llena nombre y correo (solo si están vacíos). */
function prepararContacto() {
  const usuario = typeof obtenerUsuarioGuardado === 'function' ? obtenerUsuarioGuardado() : null;
  if (!usuario) return;
  const nombre = document.getElementById('contacto-nombre');
  const correo = document.getElementById('contacto-correo');
  const completo = [usuario.nombre, usuario.apellido].filter(Boolean).join(' ');
  if (nombre && !nombre.value) nombre.value = completo || usuario.username || '';
  if (correo && !correo.value) correo.value = usuario.email || '';
}

function validarContacto({ nombre, correo, mensaje }) {
  if (!nombre) return 'Escribe tu nombre.';
  if (!correo || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)) return 'Escribe un correo válido.';
  if (mensaje.length < LARGO_MINIMO_MENSAJE) return `El mensaje debe tener al menos ${LARGO_MINIMO_MENSAJE} caracteres.`;
  if (mensaje.length > LARGO_MAXIMO_MENSAJE) return `El mensaje no puede superar los ${LARGO_MAXIMO_MENSAJE} caracteres.`;
  return null;
}

async function manejarEnvioContacto(event) {
  event.preventDefault();
  const datos = {
    nombre: document.getElementById('contacto-nombre').value.trim(),
    correo: document.getElementById('contacto-correo').value.trim(),
    motivo: document.getElementById('contacto-motivo').value,
    mensaje: document.getElementById('contacto-mensaje').value.trim(),
  };
  const error = validarContacto(datos);
  if (error) {
    mostrarError(error);
    return;
  }

  const boton = document.getElementById('contacto-enviar');
  boton.disabled = true;
  boton.textContent = 'Enviando…';
  try {
    const guardado = await enviarMensajeContacto(datos);
    document.getElementById('contacto-ticket').textContent = `Mensaje #${guardado.idMensaje}`;
    document.getElementById('contacto-ok-correo').textContent = guardado.correo;
    document.getElementById('contacto-form').hidden = true;
    document.getElementById('contacto-ok').hidden = false;
  } catch (err) {
    mostrarError(err.message);
  } finally {
    boton.disabled = false;
    boton.textContent = 'Enviar mensaje';
  }
}

/** "Enviar otro mensaje": limpia solo el texto y vuelve al formulario. */
function reiniciarContacto() {
  document.getElementById('contacto-mensaje').value = '';
  document.getElementById('contacto-motivo').selectedIndex = 0;
  actualizarContadorContacto();
  document.getElementById('contacto-ok').hidden = true;
  document.getElementById('contacto-form').hidden = false;
  prepararContacto();
}

// ── Panel admin: pestaña Mensajes ──

function formatearFechaMensaje(valor) {
  const fecha = new Date(valor);
  if (Number.isNaN(fecha.getTime())) return '';
  return fecha.toLocaleString('es-CO', {
    day: 'numeric', month: 'short', year: 'numeric', hour: 'numeric', minute: '2-digit',
  });
}

function badgeEstadoMensaje(estado) {
  const info = ESTADOS_MENSAJE[estado] || { texto: estado, badge: 'badge-gris' };
  return `<span class="badge ${info.badge}">${escaparHtml(info.texto)}</span>`;
}

function actualizarContadorSinLeer() {
  const badge = document.getElementById('mensajes-sin-leer');
  if (!badge) return;
  const nuevos = mensajesCache.filter((m) => m.estado === 'NUEVO').length;
  badge.textContent = nuevos;
  badge.hidden = nuevos === 0;
}

function renderizarFiltrosMensajes() {
  const contenedor = document.getElementById('mensajes-filtros');
  if (!contenedor) return;
  const contar = (estado) => mensajesCache.filter((m) => m.estado === estado).length;
  const opciones = [
    ['todos', 'Todos', mensajesCache.length],
    ['NUEVO', 'Nuevos', contar('NUEVO')],
    ['LEIDO', 'Leídos', contar('LEIDO')],
    ['RESPONDIDO', 'Respondidos', contar('RESPONDIDO')],
  ];
  contenedor.innerHTML = opciones.map(([valor, texto, n]) => {
    const activo = valor === filtroMensajes;
    return `<button class="product-filter cat-tint-all${activo ? ' active' : ''}" type="button"
      data-filtro-mensajes="${valor}" aria-pressed="${activo}">${texto} (${n})</button>`;
  }).join('');
}

function renderizarMensajes() {
  const tbody = document.querySelector('#admin-mensajes-table tbody');
  if (!tbody) return;
  renderizarFiltrosMensajes();
  actualizarContadorSinLeer();

  const visibles = filtroMensajes === 'todos'
    ? mensajesCache
    : mensajesCache.filter((m) => m.estado === filtroMensajes);

  if (visibles.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6">${
      mensajesCache.length === 0 ? 'Todavía no han llegado mensajes.' : 'No hay mensajes con este estado.'
    }</td></tr>`;
    return;
  }

  tbody.innerHTML = visibles.map((m) => `
    <tr class="${m.estado === 'NUEVO' ? 'mensaje-nuevo' : ''}">
      <td>${m.idMensaje}</td>
      <td>${escaparHtml(m.nombre)}<br><span class="table-subtext">${escaparHtml(m.correo)}</span></td>
      <td>${escaparHtml(m.motivoTexto)}${m.recuperacion ? '<br><span class="badge badge-ambar" style="margin-top:.3rem">Recuperar contraseña</span>' : ''}</td>
      <td>${escaparHtml(formatearFechaMensaje(m.fechaEnvio))}</td>
      <td>${badgeEstadoMensaje(m.estado)}</td>
      <td class="admin-table-actions">
        <button class="btn-mini" type="button" data-ver-mensaje="${m.idMensaje}">Ver</button>
        <button class="btn-mini btn-mini-danger" type="button" data-eliminar-mensaje="${m.idMensaje}">Eliminar</button>
      </td>
    </tr>`).join('');
}

async function cargarMensajesAdmin() {
  const tbody = document.querySelector('#admin-mensajes-table tbody');
  try {
    mensajesCache = await listarMensajesContacto();
    renderizarMensajes();
  } catch (err) {
    if (tbody) tbody.innerHTML = `<tr><td colspan="6">${escaparHtml(err.message)}</td></tr>`;
  }
}

/** Reemplaza un mensaje en la caché con la versión que devolvió el backend. */
function reemplazarMensaje(actualizado) {
  mensajesCache = mensajesCache.map((m) => (m.idMensaje === actualizado.idMensaje ? actualizado : m));
  if (mensajeAbierto && mensajeAbierto.idMensaje === actualizado.idMensaje) mensajeAbierto = actualizado;
  renderizarMensajes();
}

function enlaceRespuesta(m) {
  const asunto = `Re: ${m.motivoTexto} (mensaje #${m.idMensaje}) - BuildZone`;
  const cita = m.mensaje.split('\n').map((linea) => `> ${linea}`).join('\n');
  const cuerpo = `Hola ${m.nombre},\n\n\n\n---\nTu mensaje:\n${cita}`;
  return `mailto:${encodeURIComponent(m.correo)}?subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(cuerpo)}`;
}

function pintarModalMensaje(m) {
  document.getElementById('mensaje-modal-title').textContent = `Mensaje #${m.idMensaje}`;
  document.getElementById('mensaje-meta').innerHTML = `
    <dt>De</dt><dd>${escaparHtml(m.nombre)} · ${escaparHtml(m.correo)}</dd>
    <dt>Motivo</dt><dd>${escaparHtml(m.motivoTexto)}${m.recuperacion ? ' <span class="badge badge-ambar">Recuperar contraseña</span>' : ''}</dd>
    <dt>Recibido</dt><dd>${escaparHtml(formatearFechaMensaje(m.fechaEnvio))}</dd>
    <dt>Cuenta</dt><dd>${m.cuentaRegistrada ? 'Usuario registrado' : 'Visitante sin cuenta'}</dd>
    <dt>Estado</dt><dd>${badgeEstadoMensaje(m.estado)}</dd>`;
  document.getElementById('mensaje-texto').textContent = m.mensaje;
  document.getElementById('mensaje-responder').href = enlaceRespuesta(m);
  const marcar = document.getElementById('mensaje-marcar');
  marcar.disabled = m.estado === 'RESPONDIDO';
  marcar.textContent = m.estado === 'RESPONDIDO' ? 'Ya está respondido' : 'Marcar como respondido';
}

async function abrirMensaje(id) {
  const m = mensajesCache.find((x) => x.idMensaje === id);
  if (!m) return;
  mensajeAbierto = m;
  pintarModalMensaje(m);
  const modal = document.getElementById('mensaje-modal');
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';

  // Al abrirlo por primera vez pasa de "Nuevo" a "Leído".
  if (m.estado === 'NUEVO') {
    try {
      const actualizado = await cambiarEstadoMensajeContacto(id, 'LEIDO');
      reemplazarMensaje(actualizado);
      if (mensajeAbierto && mensajeAbierto.idMensaje === id) pintarModalMensaje(actualizado);
    } catch (err) {
      mostrarError(err.message);
    }
  }
}

function cerrarModalMensaje() {
  const modal = document.getElementById('mensaje-modal');
  if (!modal) return;
  modal.classList.remove('active');
  document.body.style.overflow = '';
  mensajeAbierto = null;
}

async function marcarMensajeRespondido() {
  if (!mensajeAbierto) return;
  const boton = document.getElementById('mensaje-marcar');
  boton.disabled = true;
  try {
    const actualizado = await cambiarEstadoMensajeContacto(mensajeAbierto.idMensaje, 'RESPONDIDO');
    reemplazarMensaje(actualizado);
    pintarModalMensaje(actualizado);
    mostrarExito(`Mensaje #${actualizado.idMensaje} marcado como respondido.`);
  } catch (err) {
    boton.disabled = false;
    mostrarError(err.message);
  }
}

async function eliminarMensaje(id) {
  if (!confirm(`¿Eliminar el mensaje #${id}? Esta acción no se puede deshacer.`)) return;
  try {
    await eliminarMensajeContacto(id);
    mensajesCache = mensajesCache.filter((m) => m.idMensaje !== id);
    renderizarMensajes();
    mostrarExito(`Mensaje #${id} eliminado.`);
  } catch (err) {
    mostrarError(err.message);
  }
}

function manejarClicMensajes(event) {
  const filtro = event.target.closest('[data-filtro-mensajes]');
  if (filtro) {
    filtroMensajes = filtro.dataset.filtroMensajes;
    renderizarMensajes();
    return;
  }
  const ver = event.target.closest('[data-ver-mensaje]');
  if (ver) {
    abrirMensaje(Number(ver.dataset.verMensaje));
    return;
  }
  const eliminar = event.target.closest('[data-eliminar-mensaje]');
  if (eliminar) eliminarMensaje(Number(eliminar.dataset.eliminarMensaje));
}

// ── Inicialización ──

function inicializarContacto() {
  const form = document.getElementById('contacto-form');
  if (form) form.addEventListener('submit', manejarEnvioContacto);

  const area = document.getElementById('contacto-mensaje');
  if (area) area.addEventListener('input', actualizarContadorContacto);

  const otro = document.getElementById('contacto-otro');
  if (otro) otro.addEventListener('click', reiniciarContacto);

  const panel = document.getElementById('admin-panel-mensajes');
  if (panel) panel.addEventListener('click', manejarClicMensajes);

  const modal = document.getElementById('mensaje-modal');
  if (modal) {
    modal.addEventListener('click', (event) => {
      if (event.target === modal || event.target.closest('[data-close-mensaje-modal]')) cerrarModalMensaje();
    });
  }
  const marcar = document.getElementById('mensaje-marcar');
  if (marcar) marcar.addEventListener('click', marcarMensajeRespondido);

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && mensajeAbierto) cerrarModalMensaje();
  });

  actualizarContadorContacto();
}

window.inicializarContacto = inicializarContacto;
window.prepararContacto = prepararContacto;
window.cargarMensajesAdmin = cargarMensajesAdmin;
