/**
 * Módulo del blog.
 *
 * - Sección "Últimas noticias" del inicio: muestra las noticias de la API
 *   (GET /api/noticias), la más reciente primero. Si el backend no responde
 *   usa los artículos locales de script.js (ARTICLES), igual que el catálogo.
 * - Modal de lectura: título, categoría, fecha, autor y el contenido en
 *   párrafos (una línea en blanco separa un párrafo del siguiente).
 * - Pestaña "Blog" del panel de administración: crear, editar y eliminar
 *   noticias (POST/PUT/DELETE /api/noticias, solo rol ADMIN).
 *
 * Depende de ui.js (escaparHtml, mostrarExito, mostrarError), api.js
 * (listarNoticias, crearNoticia, ...) y de script.js (ARTICLES,
 * CATEGORY_ICONS, lineIconSvg, tintClass, toggleArticle). Se inicializa
 * desde script.js.
 */

/** Cuántas noticias se ven en el inicio antes de "Ver más noticias". */
const NOTICIAS_VISIBLES_INICIO = 6;

/** Categorías del blog: las que ofrece el formulario del admin. */
const CATEGORIAS_BLOG = {
  'Guías': { emoji: '🧭', tint: 'cat-tint-cpu', icono: 'M14 14h36v36H14zM24 24h16v16H24zM20 6v8M28 6v8M36 6v8M44 6v8M20 50v8M28 50v8M36 50v8M44 50v8M6 20h8M6 28h8M6 36h8M6 44h8M50 20h8M50 28h8M50 36h8M50 44h8' },
  'Tutorial': { emoji: '🔧', tint: 'cat-tint-otros', icono: 'M18 4h28v56H18zM24 10h16v20H24zM36 44a4 4 0 1 1-8 0a4 4 0 1 1 8 0zM24 54h16' },
  'Novedades': { emoji: '🆕', tint: 'cat-tint-gpu', icono: 'M4 16h56v28H4zM29 30a9 9 0 1 1-18 0a9 9 0 1 1 18 0zM53 30a9 9 0 1 1-18 0a9 9 0 1 1 18 0zM22 30a2 2 0 1 1-4 0a2 2 0 1 1 4 0zM46 30a2 2 0 1 1-4 0a2 2 0 1 1 4 0zM16 44v6h24v-6' },
  'Comparativas': { emoji: '⚖️', tint: 'cat-tint-ambar', icono: 'M32 8v46M18 56h28M10 16h44M16 16l-8 18h16zM48 16l-8 18h16zM8 34a8 5 0 0 0 16 0M40 34a8 5 0 0 0 16 0' },
  'Ofertas': { emoji: '🏷️', tint: 'cat-tint-fuentes', icono: 'M8 8h22l26 26-22 22L8 30zM22 20a4 4 0 1 1-8 0a4 4 0 1 1 8 0z' },
};
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
let mostrarTodasLasNoticias = false;

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

// ── Sección "Últimas noticias" del inicio ──

function renderizarNoticias() {
  const grid = document.getElementById('news-grid');
  const boton = document.getElementById('btn-mas-noticias');
  if (!grid) return;

  if (noticiasCache.length === 0) {
    grid.innerHTML = '<p class="news-vacio">Todavía no hay noticias publicadas.</p>';
    if (boton) boton.hidden = true;
    return;
  }

  const visibles = mostrarTodasLasNoticias ? noticiasCache : noticiasCache.slice(0, NOTICIAS_VISIBLES_INICIO);
  grid.innerHTML = visibles
    .map((n) => {
      const { tint, svg } = iconoTarjetaNoticia(n);
      const fecha = formatearFechaNoticia(n.fechaPublicacion);
      return `
        <div class="news-card ${tint}" data-noticia-id="${escaparHtml(String(n.idNoticia))}" role="button" tabindex="0">
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

  if (boton) {
    boton.hidden = noticiasCache.length <= NOTICIAS_VISIBLES_INICIO;
    boton.textContent = mostrarTodasLasNoticias ? 'Ver menos' : `Ver todas las noticias (${noticiasCache.length})`;
  }
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

function manejarClicNoticias(event) {
  const tarjeta = event.target.closest('[data-noticia-id]');
  if (tarjeta) abrirNoticia(tarjeta.dataset.noticiaId);
}

function manejarTeclaNoticias(event) {
  if (event.key !== 'Enter' && event.key !== ' ') return;
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

function abrirModalNoticia(noticia) {
  const modal = document.getElementById('noticia-modal');
  if (!modal) return;

  const select = document.getElementById('noticia-categoria');
  const categorias = Object.keys(CATEGORIAS_BLOG);
  // Si la noticia tiene una categoría que no está en la lista, se agrega para no perderla.
  if (noticia && noticia.categoria && !categorias.includes(noticia.categoria)) categorias.push(noticia.categoria);
  select.innerHTML = categorias
    .map((c) => `<option value="${escaparHtml(c)}">${escaparHtml(c)}</option>`)
    .join('');

  document.getElementById('noticia-modal-title').textContent = noticia ? 'Editar noticia' : 'Nueva noticia';
  document.getElementById('noticia-form-submit').textContent = noticia ? 'Guardar cambios' : 'Publicar noticia';
  document.getElementById('noticia-id').value = noticia ? noticia.idNoticia : '';
  document.getElementById('noticia-titulo').value = noticia ? noticia.titulo : '';
  select.value = noticia && noticia.categoria ? noticia.categoria : categorias[0];
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
  await Promise.all([cargarBlogAdmin(), cargarNoticias()]);
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
      mostrarExito('Noticia actualizada.');
    } else {
      await crearNoticia(datos);
      mostrarExito('Noticia publicada.');
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
    if (!confirm('¿Eliminar esta noticia del blog? Esta acción no se puede deshacer.')) return;
    botonEliminar.disabled = true;
    try {
      await eliminarNoticia(Number(botonEliminar.dataset.eliminarNoticiaId));
      mostrarExito('Noticia eliminada.');
      await refrescarBlog();
    } catch (error) {
      mostrarError(error.message);
      botonEliminar.disabled = false;
    }
  }
}

function inicializarBlog() {
  // Primero las locales (para no ver la sección vacía) y luego las de la API.
  noticiasCache = noticiasLocales();
  renderizarNoticias();
  cargarNoticias();

  const grid = document.getElementById('news-grid');
  if (grid) {
    grid.addEventListener('click', manejarClicNoticias);
    grid.addEventListener('keydown', manejarTeclaNoticias);
  }

  const botonMas = document.getElementById('btn-mas-noticias');
  if (botonMas) {
    botonMas.addEventListener('click', () => {
      mostrarTodasLasNoticias = !mostrarTodasLasNoticias;
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
window.cargarBlogAdmin = cargarBlogAdmin;
