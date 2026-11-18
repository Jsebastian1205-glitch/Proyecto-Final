/**
 * Módulo del blog.
 *
 * - Página "Blog": muestra las noticias de la API (GET /api/noticias), la
 *   más reciente primero, con filtros por categoría. Si el backend no
 *   responde usa los artículos locales de script.js (ARTICLES), igual que
 *   el catálogo.
 * - Modal de lectura: título, categoría, fecha, autor y el contenido en
 *   párrafos (una línea en blanco separa un párrafo del siguiente).
 * - Botón "Crear publicación" de la página Blog: lo ven el administrador y
 *   los usuarios con un plan activo. Cada quien ve "Editar" y "Eliminar" en
 *   sus propias publicaciones (el administrador, en todas).
 * - Pestaña "Blog" del panel de administración: crear, editar y eliminar
 *   cualquier noticia (POST/PUT/DELETE /api/noticias).
 *
 * Depende de ui.js (escaparHtml, mostrarExito, mostrarError), api.js
 * (listarNoticias, crearNoticia, ...) y de script.js (ARTICLES,
 * CATEGORY_ICONS, lineIconSvg, tintClass, toggleArticle). Se inicializa
 * desde script.js.
 */

/** Categorías del blog: las que ofrece el formulario del admin. */
const CATEGORIAS_BLOG = {
  'Guías': { emoji: '🧭', tint: 'cat-tint-cpu', icono: 'M14 14h36v36H14zM24 24h16v16H24zM20 6v8M28 6v8M36 6v8M44 6v8M20 50v8M28 50v8M36 50v8M44 50v8M6 20h8M6 28h8M6 36h8M6 44h8M50 20h8M50 28h8M50 36h8M50 44h8' },
  'Tutorial': { emoji: '🔧', tint: 'cat-tint-otros', icono: 'M18 4h28v56H18zM24 10h16v20H24zM36 44a4 4 0 1 1-8 0a4 4 0 1 1 8 0zM24 54h16' },
  'Novedades': { emoji: '🆕', tint: 'cat-tint-gpu', icono: 'M4 16h56v28H4zM29 30a9 9 0 1 1-18 0a9 9 0 1 1 18 0zM53 30a9 9 0 1 1-18 0a9 9 0 1 1 18 0zM22 30a2 2 0 1 1-4 0a2 2 0 1 1 4 0zM46 30a2 2 0 1 1-4 0a2 2 0 1 1 4 0zM16 44v6h24v-6' },
  'Comparativas': { emoji: '⚖️', tint: 'cat-tint-ambar', icono: 'M32 8v46M18 56h28M10 16h44M16 16l-8 18h16zM48 16l-8 18h16zM8 34a8 5 0 0 0 16 0M40 34a8 5 0 0 0 16 0' },
  'Ofertas': { emoji: '🏷️', tint: 'cat-tint-fuentes', icono: 'M8 8h22l26 26-22 22L8 30zM22 20a4 4 0 1 1-8 0a4 4 0 1 1 8 0z' },
  'Notas': { emoji: '📝', tint: 'cat-tint-ram', icono: 'M14 6h28l8 8v44H14zM42 6v8h8M22 24h20M22 32h20M22 40h12M38 52l14-14 4 4-14 14h-4z' },
};

/**
 * Tipos de publicación del botón "Crear publicación" de la página Blog.
 * Cada uno abre el formulario con su categoría ya elegida.
 */
const TIPOS_PUBLICACION = [
  { categoria: 'Novedades', nombre: 'Noticia', titulo: 'Nueva noticia', ayuda: 'Lanzamientos y novedades del mundo PC' },
  { categoria: 'Tutorial', nombre: 'Tutorial', titulo: 'Nuevo tutorial', ayuda: 'Paso a paso para hacer algo' },
  { categoria: 'Guías', nombre: 'Guía', titulo: 'Nueva guía', ayuda: 'Consejos para elegir o comprar' },
  { categoria: 'Notas', nombre: 'Nota', titulo: 'Nueva nota', ayuda: 'Un aviso o comentario corto' },
  { categoria: 'Comparativas', nombre: 'Comparativa', titulo: 'Nueva comparativa', ayuda: 'Un producto frente a otro' },
  { categoria: 'Ofertas', nombre: 'Oferta', titulo: 'Nueva oferta', ayuda: 'Descuentos y precios destacados' },
];
const CATEGORIA_BLOG_POR_DEFECTO = { emoji: '📰', tint: 'cat-tint-otros', icono: 'M16 6h24l10 10v42H16zM40 6v10h10M22 28h20M22 36h20M22 44h14' };

/**
 * Si el título habla de un componente (RAM, GPU, refrigeración...), la
 * tarjeta usa el ícono y el color de esa categoría del catálogo; si no, los
 * de la categoría del blog.
 */
const COMPONENTES_EN_TITULO = [
  [/\bram\b|memoria/, 'ram'],
  [/gpu|gr[aá]fica|rtx|radeon/, 'gpu'],
  [/refrigera|disipador|cooler/, 'refrigeracion'],
  [/ssd|nvme|almacenamiento|disco/, 'almacenamiento'],
  [/monitor|pantalla/, 'monitores'],
  [/fuente de poder|psu/, 'fuentes'],
  [/placa madre|motherboard/, 'placas-madre'],
];

let noticiasCache = [];
let noticiasAdminCache = [];
/** Ids de las publicaciones que la sesión actual puede editar ('todas' = admin). */
let publicacionesEditables = new Set();
/** Categoría elegida en los filtros de la página Blog ('todas' = sin filtro). */
let categoriaBlogActiva = 'todas';

/** Los artículos locales de script.js con el mismo formato que la API. */
function noticiasLocales() {
  return Object.entries(typeof ARTICLES === 'object' ? ARTICLES : {}).map(([clave, a]) => ({
    idNoticia: clave,
    titulo: a.title,
    categoria: a.tag,
    resumen: a.body.split(/(?<=[.!?])\s/)[0],
    contenido: a.body,
    fechaPublicacion: null,
    autor: 'Equipo BuildZone',
  }));
}

function estiloCategoriaBlog(categoria) {
  return CATEGORIAS_BLOG[categoria] || CATEGORIA_BLOG_POR_DEFECTO;
}

function iconoTarjetaNoticia(noticia) {
  const titulo = (noticia.titulo || '').toLowerCase();
  const componente = COMPONENTES_EN_TITULO.find(([patron]) => patron.test(titulo));
  if (componente && typeof CATEGORY_ICONS === 'object' && CATEGORY_ICONS[componente[1]]) {
    return { tint: tintClass(componente[1]), svg: lineIconSvg(CATEGORY_ICONS[componente[1]], 64, 76, '') };
  }
  const estilo = estiloCategoriaBlog(noticia.categoria);
  return { tint: estilo.tint, svg: lineIconSvg(estilo.icono, 64, 76, '') };
}

/** "2026-11-18T10:30:00" -> "18 de noviembre de 2026". */
function formatearFechaNoticia(fecha) {
  if (!fecha) return '';
  const valor = new Date(fecha);
  if (Number.isNaN(valor.getTime())) return '';
  return valor.toLocaleDateString('es-CO', { day: 'numeric', month: 'long', year: 'numeric' });
}

// ── Página "Blog" ──

/** Botones de filtro: "Todas" y una por cada categoría que tenga noticias. */
function renderizarFiltrosBlog() {
  const contenedor = document.getElementById('blog-filtros');
  if (!contenedor) return;

  const conteo = new Map();
  noticiasCache.forEach((n) => {
    const categoria = n.categoria || 'Noticias';
    conteo.set(categoria, (conteo.get(categoria) || 0) + 1);
  });
  if (categoriaBlogActiva !== 'todas' && !conteo.has(categoriaBlogActiva)) {
    categoriaBlogActiva = 'todas';
  }
  // Primero las categorías del formulario (en su orden) y luego cualquier otra
  const orden = [...Object.keys(CATEGORIAS_BLOG), ...conteo.keys()]
    .filter((c, i, lista) => conteo.has(c) && lista.indexOf(c) === i);

  const boton = (valor, texto, tint, cantidad) => {
    const activa = valor === categoriaBlogActiva;
    return `<button class="product-filter ${tint}${activa ? ' active' : ''}" type="button"
      data-blog-categoria="${escaparHtml(valor)}" aria-pressed="${activa}">${escaparHtml(texto)} <span class="blog-filtro-n">${cantidad}</span></button>`;
  };
  contenedor.hidden = noticiasCache.length === 0;
  contenedor.innerHTML = [
    boton('todas', 'Todas', 'cat-tint-all', noticiasCache.length),
    ...orden.map((c) => boton(c, c, (CATEGORIAS_BLOG[c] || CATEGORIA_BLOG_POR_DEFECTO).tint, conteo.get(c))),
  ].join('');
}

function renderizarNoticias() {
  const grid = document.getElementById('news-grid');
  if (!grid) return;
  renderizarFiltrosBlog();

  if (noticiasCache.length === 0) {
    grid.innerHTML = '<p class="news-vacio">Todavía no hay noticias publicadas.</p>';
    return;
  }

  const visibles = categoriaBlogActiva === 'todas'
    ? noticiasCache
    : noticiasCache.filter((n) => (n.categoria || 'Noticias') === categoriaBlogActiva);
  grid.innerHTML = visibles
    .map((n) => {
      const { tint, svg } = iconoTarjetaNoticia(n);
      const fecha = formatearFechaNoticia(n.fechaPublicacion);
      return `
        <div class="news-card ${tint}" data-noticia-id="${escaparHtml(String(n.idNoticia))}" role="button" tabindex="0">
          ${puedeEditar(n.idNoticia) ? `<div class="news-acciones">
            <button type="button" class="news-accion" data-editar-publicacion="${escaparHtml(String(n.idNoticia))}" title="Editar">✏️ Editar</button>
            <button type="button" class="news-accion news-accion-borrar" data-eliminar-publicacion="${escaparHtml(String(n.idNoticia))}" title="Eliminar">🗑️</button>
          </div>` : ''}
          <div class="news-thumb">${svg}</div>
          <div class="news-body">
            <div class="news-tag">${escaparHtml(n.categoria || 'Noticias')}</div>
            <div class="news-title">${escaparHtml(n.titulo)}</div>
            ${n.resumen ? `<p class="news-resumen">${escaparHtml(n.resumen)}</p>` : ''}
            <div class="news-link">Leer más →${fecha ? `<span class="news-fecha">${fecha}</span>` : ''}</div>
          </div>
        </div>`;
    })
    .join('');
}

/** Trae las noticias de la API; si no responde, deja las locales. */
async function cargarNoticias() {
  try {
    noticiasCache = await listarNoticias();
  } catch (error) {
    console.info('[BuildZone] Blog local en uso (API no disponible):', error.message);
    noticiasCache = noticiasLocales();
  }
  renderizarNoticias();
}

function abrirNoticia(idNoticia) {
  const noticia = noticiasCache.find((n) => String(n.idNoticia) === String(idNoticia));
  if (!noticia) return;

  const fecha = formatearFechaNoticia(noticia.fechaPublicacion);
  const meta = [fecha, noticia.autor ? `por ${noticia.autor}` : ''].filter(Boolean).join(' · ');
  const parrafos = noticia.contenido
    .split(/\n\s*\n/)
    .map((p) => p.trim())
    .filter(Boolean)
    .map((p) => `<p>${escaparHtml(p).replace(/\n/g, '<br>')}</p>`)
    .join('');

  document.getElementById('article-icon').textContent = estiloCategoriaBlog(noticia.categoria).emoji;
  document.getElementById('article-tag').textContent = noticia.categoria || 'Noticias';
  document.getElementById('article-title').textContent = noticia.titulo;
  const metaEl = document.getElementById('article-meta');
  if (metaEl) metaEl.textContent = meta;
  document.getElementById('article-body').innerHTML = parrafos;

  toggleArticle(true);
}

function puedeEditar(id) {
  return publicacionesEditables === 'todas' || publicacionesEditables.has(Number(id));
}

async function eliminarPublicacion(id, boton) {
  if (!confirm('¿Eliminar esta publicación del blog? Esta acción no se puede deshacer.')) return;
  if (boton) boton.disabled = true;
  try {
    await eliminarNoticia(Number(id));
    mostrarExito('Publicación eliminada.');
    await refrescarBlog();
  } catch (error) {
    mostrarError(error.message);
    if (boton) boton.disabled = false;
  }
}

function manejarClicNoticias(event) {
  const editar = event.target.closest('[data-editar-publicacion]');
  if (editar) {
    const id = Number(editar.dataset.editarPublicacion);
    abrirModalNoticia(noticiasCache.find((n) => n.idNoticia === id) || null);
    return;
  }
  const eliminar = event.target.closest('[data-eliminar-publicacion]');
  if (eliminar) {
    eliminarPublicacion(eliminar.dataset.eliminarPublicacion, eliminar);
    return;
  }
  const tarjeta = event.target.closest('[data-noticia-id]');
  if (tarjeta) abrirNoticia(tarjeta.dataset.noticiaId);
}

function manejarTeclaNoticias(event) {
  if (event.key !== 'Enter' && event.key !== ' ') return;
  if (event.target.closest('button')) return; // los botones Editar/Eliminar se manejan solos
  const tarjeta = event.target.closest('[data-noticia-id]');
  if (!tarjeta) return;
  event.preventDefault();
  abrirNoticia(tarjeta.dataset.noticiaId);
}

// ── Panel de administración: pestaña Blog ──

function renderizarBlogAdmin(noticias) {
  const tbody = document.querySelector('#admin-blog-table tbody');
  if (!tbody) return;

  if (!noticias || noticias.length === 0) {
    tbody.innerHTML = '<tr><td colspan="4">No hay noticias publicadas.</td></tr>';
    return;
  }

  tbody.innerHTML = noticias
    .map(
      (n) => `
        <tr>
          <td>${escaparHtml(n.titulo)}<br><span class="table-subtext">por ${escaparHtml(n.autor || '')}</span></td>
          <td>${escaparHtml(n.categoria || '—')}</td>
          <td>${formatearFechaNoticia(n.fechaPublicacion)}</td>
          <td class="admin-table-actions">
            <button class="btn-mini" data-editar-noticia-id="${n.idNoticia}">Editar</button>
            <button class="btn-mini btn-mini-danger" data-eliminar-noticia-id="${n.idNoticia}">Eliminar</button>
          </td>
        </tr>`
    )
    .join('');
}

async function cargarBlogAdmin() {
  const tbody = document.querySelector('#admin-blog-table tbody');
  if (tbody) tbody.innerHTML = '<tr><td colspan="4">Cargando…</td></tr>';
  try {
    noticiasAdminCache = await listarNoticias();
    renderizarBlogAdmin(noticiasAdminCache);
  } catch (error) {
    if (tbody) tbody.innerHTML = `<tr><td colspan="4">Error al cargar el blog: ${escaparHtml(error.message)}</td></tr>`;
  }
}

/**
 * Abre el formulario. Con una noticia, para editarla; sin ella, para crear
 * una nueva (tipo = uno de TIPOS_PUBLICACION para dejar su categoría elegida).
 */
function abrirModalNoticia(noticia, tipo) {
  const modal = document.getElementById('noticia-modal');
  if (!modal) return;

  const select = document.getElementById('noticia-categoria');
  const categorias = Object.keys(CATEGORIAS_BLOG);
  // Si la noticia tiene una categoría que no está en la lista, se agrega para no perderla.
  if (noticia && noticia.categoria && !categorias.includes(noticia.categoria)) categorias.push(noticia.categoria);
  select.innerHTML = categorias
    .map((c) => `<option value="${escaparHtml(c)}">${escaparHtml(c)}</option>`)
    .join('');

  const tituloNuevo = tipo ? tipo.titulo : 'Nueva publicación';
  document.getElementById('noticia-modal-title').textContent = noticia ? 'Editar publicación' : tituloNuevo;
  document.getElementById('noticia-form-submit').textContent = noticia ? 'Guardar cambios' : 'Publicar';
  document.getElementById('noticia-id').value = noticia ? noticia.idNoticia : '';
  document.getElementById('noticia-titulo').value = noticia ? noticia.titulo : '';
  select.value = noticia && noticia.categoria ? noticia.categoria : (tipo ? tipo.categoria : categorias[0]);
  document.getElementById('noticia-resumen').value = noticia ? noticia.resumen || '' : '';
  document.getElementById('noticia-contenido').value = noticia ? noticia.contenido : '';

  modal.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function cerrarModalNoticia() {
  const modal = document.getElementById('noticia-modal');
  if (!modal) return;
  modal.classList.remove('active');
  document.body.style.overflow = '';
}

/** Tras cualquier cambio se refresca la tabla del admin y el blog del inicio. */
async function refrescarBlog() {
  await Promise.all([cargarBlogAdmin(), cargarNoticias(), actualizarAccionesBlog()]);
}

async function manejarEnvioNoticia(event) {
  event.preventDefault();
  const id = document.getElementById('noticia-id').value;
  const datos = {
    titulo: document.getElementById('noticia-titulo').value.trim(),
    categoria: document.getElementById('noticia-categoria').value,
    resumen: document.getElementById('noticia-resumen').value.trim() || null,
    contenido: document.getElementById('noticia-contenido').value.trim(),
  };
  const boton = document.getElementById('noticia-form-submit');

  try {
    if (boton) boton.disabled = true;
    if (id) {
      await actualizarNoticia(Number(id), datos);
      mostrarExito('Publicación actualizada.');
    } else {
      await crearNoticia(datos);
      mostrarExito('Publicación creada.');
    }
    cerrarModalNoticia();
    await refrescarBlog();
  } catch (error) {
    mostrarError(error.message);
  } finally {
    if (boton) boton.disabled = false;
  }
}

async function manejarClicBlogAdmin(event) {
  if (event.target.closest('#btn-nueva-noticia')) {
    abrirModalNoticia(null);
    return;
  }

  const botonEditar = event.target.closest('[data-editar-noticia-id]');
  if (botonEditar) {
    const noticia = noticiasAdminCache.find((n) => n.idNoticia === Number(botonEditar.dataset.editarNoticiaId));
    abrirModalNoticia(noticia || null);
    return;
  }

  const botonEliminar = event.target.closest('[data-eliminar-noticia-id]');
  if (botonEliminar) {
    await eliminarPublicacion(botonEliminar.dataset.eliminarNoticiaId, botonEliminar);
  }
}

// ── Botón "Crear publicación" de la página Blog (admin y usuarios con plan) ──

function alternarMenuCrear(abrir) {
  const menu = document.getElementById('blog-crear-menu');
  const boton = document.getElementById('btn-crear-publicacion');
  if (!menu || !boton) return;
  menu.hidden = !abrir;
  boton.setAttribute('aria-expanded', String(abrir));
}

let consultaAccionesBlog = 0;

/**
 * Decide qué ve la sesión actual en la página Blog:
 * - Administrador: botón "Crear publicación" y Editar/Eliminar en todas.
 * - Usuario con plan de pago activo (mensual o anual): el botón y
 *   Editar/Eliminar en las suyas. El plan Gratuito no habilita publicar.
 * - Usuario sin plan o visitante: un aviso con el enlace a Planes.
 * Lo llaman auth.js (al entrar o salir), showPage('blog') y refrescarBlog.
 */
async function actualizarAccionesBlog() {
  const zona = document.getElementById('blog-crear');
  const aviso = document.getElementById('blog-aviso-plan');
  if (!zona) return;
  const consulta = ++consultaAccionesBlog;

  const conSesion = !!(window.estaAutenticado && window.estaAutenticado());
  const admin = conSesion && !!(window.esAdmin && window.esAdmin());
  let conPlan = false;
  let editables = new Set();

  if (admin) {
    editables = 'todas';
  } else if (conSesion) {
    const [activa, mias] = await Promise.all([
      obtenerMiSuscripcionActiva().catch(() => null),
      listarMisNoticias().catch(() => []),
    ]);
    // Cuenta solo un plan de pago (mensual o anual): el Gratuito no habilita publicar
    conPlan = !!(activa && activa.plan && Number(activa.plan.precio) > 0);
    editables = new Set((mias || []).map((n) => n.idNoticia));
  }
  if (consulta !== consultaAccionesBlog) return; // llegó una consulta más nueva

  const puedePublicar = admin || conPlan;
  zona.hidden = !puedePublicar;
  if (!puedePublicar) alternarMenuCrear(false);
  if (aviso) {
    aviso.hidden = puedePublicar;
    const texto = document.getElementById('blog-aviso-texto');
    if (texto) {
      texto.textContent = conSesion
        ? '¿Quieres publicar? Con un plan Premium, mensual o anual, puedes crear noticias, tutoriales, guías y notas.'
        : '¿Quieres publicar? Inicia sesión y activa un plan Premium, mensual o anual, para crear noticias, tutoriales, guías y notas.';
    }
  }
  publicacionesEditables = editables;
  renderizarNoticias();
}

function inicializarMenuCrear() {
  const opciones = document.getElementById('blog-crear-opciones');
  const boton = document.getElementById('btn-crear-publicacion');
  if (!opciones || !boton) return;

  opciones.innerHTML = TIPOS_PUBLICACION.map((tipo, i) => {
    const { emoji, tint } = CATEGORIAS_BLOG[tipo.categoria] || CATEGORIA_BLOG_POR_DEFECTO;
    return `<button class="blog-crear-opcion ${tint}" type="button" data-tipo-publicacion="${i}">
        <span class="blog-crear-emoji">${emoji}</span>
        <span><strong>${escaparHtml(tipo.nombre)}</strong><small>${escaparHtml(tipo.ayuda)}</small></span>
      </button>`;
  }).join('');

  boton.addEventListener('click', (event) => {
    event.stopPropagation();
    alternarMenuCrear(document.getElementById('blog-crear-menu').hidden);
  });
  opciones.addEventListener('click', (event) => {
    const opcion = event.target.closest('[data-tipo-publicacion]');
    if (!opcion) return;
    alternarMenuCrear(false);
    abrirModalNoticia(null, TIPOS_PUBLICACION[Number(opcion.dataset.tipoPublicacion)]);
  });
  // Clic fuera del menú o tecla Escape: se cierra
  document.addEventListener('click', (event) => {
    if (!event.target.closest('#blog-crear')) alternarMenuCrear(false);
  });
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') alternarMenuCrear(false);
  });
  actualizarAccionesBlog();
}

function inicializarBlog() {
  inicializarMenuCrear();
  // Primero las locales (para no ver la sección vacía) y luego las de la API.
  noticiasCache = noticiasLocales();
  renderizarNoticias();
  cargarNoticias();

  const grid = document.getElementById('news-grid');
  if (grid) {
    grid.addEventListener('click', manejarClicNoticias);
    grid.addEventListener('keydown', manejarTeclaNoticias);
  }

  const filtros = document.getElementById('blog-filtros');
  if (filtros) {
    filtros.addEventListener('click', (event) => {
      const boton = event.target.closest('[data-blog-categoria]');
      if (!boton) return;
      categoriaBlogActiva = boton.dataset.blogCategoria;
      renderizarNoticias();
    });
  }

  const panel = document.getElementById('admin-panel-blog');
  if (panel) panel.addEventListener('click', manejarClicBlogAdmin);

  const form = document.getElementById('noticia-form');
  if (form) form.addEventListener('submit', manejarEnvioNoticia);

  const modal = document.getElementById('noticia-modal');
  if (modal) {
    modal.addEventListener('click', (event) => {
      if (event.target === modal || event.target.closest('[data-close-noticia-modal]')) {
        cerrarModalNoticia();
      }
    });
  }
}

window.inicializarBlog = inicializarBlog;
window.actualizarAccionesBlog = actualizarAccionesBlog;
window.cargarBlogAdmin = cargarBlogAdmin;
