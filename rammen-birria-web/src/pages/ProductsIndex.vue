<script setup lang="ts">
import { ref, watch, onMounted } from "vue";
import { useRoute, useRouter, RouterLink } from "vue-router";
import { getProducts, deleteProduct, type Product } from "@/api/products";
import AppTopBar from "@/components/AppTopBar.vue";
import { isAuthenticated } from "@/api/http";
import { useCart } from "@/composables/useCart";
import { apiURL } from "@/utils/apiUrl";

const { add } = useCart();
const route = useRoute();
const router = useRouter();

const products = ref<Product[]>([]);
const loading = ref(true);
const error = ref("");
const categoryId = ref<number | null>(null);

const currency = (n: number | string) =>
  new Intl.NumberFormat("es-MX", { style: "currency", currency: "MXN", maximumFractionDigits: 0 })
    .format(Number(n));

const finalPrice = (p: Product) =>
  Number((p as any).price_with_discount ?? p.price);

const hasDiscount = (p: Product) =>
  finalPrice(p) > 0 && Number(p.price) > 0 && finalPrice(p) < Number(p.price);

const discountPercent = (p: Product) => {
  const dp = (p as any).discount_percent;
  if (typeof dp === "number") return dp;
  const base = Number(p.price);
  const fin  = finalPrice(p);
  if (!base || fin >= base) return 0;
  return Math.round((1 - fin / base) * 100);
};

onMounted(() => {
  const q = route.query.category_id;
  if (typeof q === "string" && q !== "") {
    const n = Number(q);
    categoryId.value = Number.isNaN(n) ? null : n;
  }
  fetchList();
});

watch(() => route.query.category_id, (q) => {
  const n = typeof q === "string" ? Number(q) : NaN;
  categoryId.value = Number.isNaN(n) ? null : n;
  fetchList();
});

watch(categoryId, (val) => {
  const q = val ? { category_id: String(val) } : {};
  router.replace({ query: q });
});

async function fetchList() {
  loading.value = true;
  error.value = "";
  try {
    products.value = await getProducts({ category_id: categoryId.value ?? undefined });
  } catch (e: any) {
    error.value = e?.message || "No se pudieron cargar los productos.";
  } finally {
    loading.value = false;
  }
}

function addToCart(p: Product) { add(p, 1); }

async function remove(p: Product) {
  if (!confirm(`¿Eliminar "${p.name}"?`)) return;
  try {
    await deleteProduct(p.id);
    products.value = products.value.filter((x) => x.id !== p.id);
  } catch (e: any) {
    error.value = e?.message || "No se pudo eliminar el producto.";
  }
}
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- TopBar con filtro de categorías integrado -->
    <AppTopBar show-category-filter v-model:category-id="categoryId" />

    <div class="max-w-6xl mx-auto p-4 md:p-6">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-bold">Productos</h1>

        <RouterLink
          v-if="isAuthenticated"
          :to="{ name: 'products-new' }"
          class="bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg px-3 py-2 text-sm"
        >
          Nuevo producto
        </RouterLink>
      </div>

      <div v-if="error" class="mb-4 bg-red-50 text-red-700 rounded px-3 py-2 text-sm">
        {{ error }}
      </div>

      <div v-if="loading" class="text-sm text-gray-500">Cargando productos…</div>

      <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        <div
          v-for="p in products"
          :key="p.id"
          class="bg-white rounded-xl border shadow-sm overflow-hidden flex flex-col"
        >
          <div class="aspect-[4/3] bg-gray-100">
            <img
              v-if="p.image_url"
              :src="apiURL(p.image_url) || undefined"
              :alt="p.name"
              class="w-full h-full object-cover"
              loading="lazy"
            />
          </div>

          <div class="p-3 flex-1 flex flex-col">
            <div class="flex items-start justify-between gap-2">
              <h3 class="font-semibold line-clamp-2">{{ p.name }}</h3>
              <div class="text-right min-w-[90px]">
                <template v-if="hasDiscount(p)">
                  <div class="text-xs text-gray-400 line-through">
                    {{ currency(p.price) }}
                  </div>
                  <div class="text-indigo-700 font-semibold">
                    {{ currency(finalPrice(p)) }}
                  </div>
                  <span class="inline-block mt-1 text-[10px] px-2 py-0.5 rounded-full
                              bg-indigo-50 text-indigo-700 border border-indigo-100">
                    -{{ discountPercent(p) }}%
                  </span>
                </template>

                <template v-else>
                  <span class="text-indigo-700 font-semibold">
                    {{ currency(p.price) }}
                  </span>
                </template>
              </div>
            </div>

            <p class="text-sm text-gray-500 mt-1 line-clamp-2">
              {{ p.description || "—" }}
            </p>

            <div class="mt-2 flex flex-wrap gap-1">
              <span
                v-for="c in p.categories ?? []"
                :key="c.id"
                class="text-[10px] px-2 py-0.5 rounded-full bg-gray-100 border"
              >
                {{ c.name }}
              </span>
            </div>

            <div class="mt-auto pt-3 flex gap-2">
              <button
                v-if="!isAuthenticated"
                type="button"
                class="w-full bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg px-3 py-2 text-sm"
                @click="addToCart(p)"
              >
                Agregar al carrito
              </button>

              <template v-else>
                <RouterLink
                  :to="{ name: 'products-edit', params: { id: p.id } }"
                  class="flex-1 border rounded-lg px-3 py-2 text-sm hover:bg-gray-50 text-center"
                >
                  Editar
                </RouterLink>
                <button
                  type="button"
                  class="flex-1 border rounded-lg px-3 py-2 text-sm hover:bg-red-50 text-red-700 border-red-200"
                  @click="remove(p)"
                >
                  Eliminar
                </button>
              </template>
            </div>
          </div>
        </div>

        <div v-if="!products.length && !loading" class="col-span-full text-center text-sm text-gray-500 py-10">
          No hay productos para esta categoría.
        </div>
      </div>
    </div>
  </div>
</template>
