<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { getProduct, createProduct, updateProduct, type Product } from "@/api/products";
import { fetchCategories, type Category } from "@/api/categories";
import { apiURL } from "@/utils/apiUrl";

const route = useRoute();
const router = useRouter();

const categories = ref<Category[]>([]);
const selectedCategoryIds = ref<number[]>([]);

const productId = computed(() => {
  const raw = Number(route.params.id);
  return Number.isNaN(raw) ? null : raw;
});
const isEdit = computed(() => productId.value !== null);

/** Form state */
const title = computed(() => (isEdit.value ? "Editar producto" : "Nuevo producto"));

const name = ref("");
const price = ref<number | null>(null);
const description = ref("");
const available = ref(true);

const file = ref<File | null>(null);
const preview = ref<string | null>(null);

const loading = ref(false);
const loadingInit = ref(true);
const error = ref("");

/** helpers */
function setFormFromProduct(p: Product) {
  name.value = p.name;
  price.value = Number(p.price);
  description.value = p.description || "";
  available.value = p.available;
  preview.value = p.image_url ? apiURL(p.image_url) : null;
  selectedCategoryIds.value = (p.categories ?? []).map((c) => c.id);
}

function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement;
  const f = input.files?.[0] || null;
  file.value = f;
  if (f) preview.value = URL.createObjectURL(f);
}

function validate() {
  if (!name.value?.trim()) {
    error.value = "El nombre es obligatorio.";
    return false;
  }
  if (price.value === null || Number.isNaN(Number(price.value))) {
    error.value = "El precio es obligatorio y debe ser numérico.";
    return false;
  }
  if (Number(price.value) < 0) {
    error.value = "El precio no puede ser negativo.";
    return false;
  }
  return true;
}

/** Carga inicial */
onMounted(async () => {
  try {
    categories.value = await fetchCategories();

    if (isEdit.value && productId.value !== null) {
      const p = await getProduct(productId.value);
      setFormFromProduct(p);
    }
  } catch (e: any) {
    error.value =
      e?.message ||
      e?.response?.data?.error ||
      "Ocurrió un error al cargar datos iniciales.";
  } finally {
    loadingInit.value = false;
  }
});

async function submit() {
  error.value = "";
  if (!validate()) return;

  loading.value = true;
  try {
    const payload = {
      name: name.value.trim(),
      price: Number(price.value),
      description: description.value,
      available: available.value,
      file: file.value || undefined,
      category_ids: selectedCategoryIds.value,
    };

    if (isEdit.value && productId.value !== null) {
      await updateProduct(productId.value, payload);
    } else {
      await createProduct(payload);
    }
    router.push({ name: "products-index" });
  } catch (e: any) {
    const data = e?.response?.data;
    if (Array.isArray(data?.errors)) {
      error.value = data.errors.join("\n");
    } else if (data?.errors && typeof data.errors === "object") {
      const flat = Object.values<string[]>(data.errors as any).flat();
      error.value = flat.join("\n");
    } else {
      error.value = data?.error || e?.message || "No se pudo guardar.";
    }
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="max-w-2xl mx-auto p-6">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">{{ title }}</h1>
      <button
        type="button"
        class="border rounded px-3 py-1 hover:bg-gray-50"
        @click="$router.push({ name: 'products-index' })"
      >
        Volver
      </button>
    </div>

    <!-- Loading inicial -->
    <div v-if="loadingInit" class="mb-4 text-sm text-gray-500">
      Cargando datos…
    </div>

    <!-- Error box -->
    <div
      v-if="error"
      class="mb-4 bg-red-50 text-red-700 rounded px-3 py-2 text-sm whitespace-pre-line"
    >
      {{ error }}
    </div>

    <!-- Form -->
    <form
      v-if="!loadingInit"
      @submit.prevent="submit"
      class="space-y-4 bg-white rounded-2xl p-4 shadow-sm border"
    >
      <div class="grid md:grid-cols-2 gap-4">
        <div>
          <label class="block text-sm text-gray-600 mb-1">Nombre</label>
          <input
            v-model="name"
            type="text"
            class="w-full border rounded-lg px-3 py-2"
            placeholder="Ramen especial"
            required
          />
        </div>

        <div>
          <label class="block text-sm text-gray-600 mb-1">Precio</label>
          <input
            v-model.number="price"
            type="number"
            step="0.01"
            min="0"
            class="w-full border rounded-lg px-3 py-2"
            required
          />
        </div>
      </div>

      <div>
        <label class="block text-sm text-gray-600 mb-1">Descripción</label>
        <textarea
          v-model="description"
          rows="3"
          class="w-full border rounded-lg px-3 py-2"
          placeholder="Una breve descripción"
        />
      </div>

      <div>
        <label class="block text-sm text-gray-600 mb-2">Categorías</label>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
          <label
            v-for="cat in categories"
            :key="cat.id"
            class="flex items-center gap-2 border rounded-lg px-3 py-2 hover:bg-gray-50"
          >
            <input
              type="checkbox"
              :value="cat.id"
              v-model="selectedCategoryIds"
              class="h-4 w-4"
            />
            <span class="text-sm">{{ cat.name }}</span>
          </label>
        </div>

        <p class="text-xs text-gray-500 mt-2">
          Puedes asignar múltiples categorías.
        </p>

        <div v-if="selectedCategoryIds.length" class="mt-2 flex flex-wrap gap-2">
          <span
            v-for="cid in selectedCategoryIds"
            :key="cid"
            class="inline-flex items-center text-xs bg-indigo-50 text-indigo-700 rounded-full px-2 py-1 border border-indigo-100"
          >
            {{ categories.find((c) => c.id === cid)?.name ?? `#${cid}` }}
          </span>
        </div>
      </div>

      <div class="flex items-center gap-3">
        <input id="available" v-model="available" type="checkbox" class="h-4 w-4" />
        <label for="available" class="text-sm">Disponible</label>
      </div>

      <div class="grid md:grid-cols-2 gap-4 items-start">
        <div>
          <label class="block text-sm text-gray-600 mb-1">
            Imagen (JPG/PNG/WEBP, máx 5MB)
          </label>
          <input type="file" accept="image/*" @change="onFileChange" class="w-full" />
          <p class="text-xs text-gray-500 mt-1">
            En edición: si no seleccionas archivo, se mantiene la imagen actual.
          </p>
        </div>

        <div v-if="preview" class="justify-self-end">
          <img :src="preview" alt="preview" class="h-28 w-28 rounded-lg object-cover border" />
        </div>
      </div>

      <button
        type="submit"
        :disabled="loading"
        class="bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg px-4 py-2 disabled:opacity-50"
      >
        {{ loading ? "Guardando..." : (isEdit ? "Guardar cambios" : "Crear") }}
      </button>
    </form>
  </div>
</template>
