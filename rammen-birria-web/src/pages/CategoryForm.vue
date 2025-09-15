<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import {
  getCategory,
  createCategory,
  updateCategory,
  type Category,
} from "@/api/categories";

const route = useRoute();
const router = useRouter();

const categoryId = computed(() => {
  const n = Number(route.params.id);
  return Number.isNaN(n) ? null : n;
});
const isEdit = computed(() => categoryId.value !== null);

const title = computed(() =>
  isEdit.value ? "Editar categoría" : "Nueva categoría"
);

const name = ref("");
const description = ref("");
const discount = ref<number | null>(null);

const loadingInit = ref(true);
const loading = ref(false);
const error = ref("");

function validate(): boolean {
  if (!name.value.trim()) {
    error.value = "El nombre es obligatorio.";
    return false;
  }
  if (discount.value != null) {
    const d = Number(discount.value);
    if (Number.isNaN(d) || d < 0 || d > 100) {
      error.value = "El descuento debe ser un número entre 0 y 100.";
      return false;
    }
  }
  return true;
}

function setForm(c: Category) {
  name.value = c.name;
  description.value = c.description ?? "";
  discount.value = c.discount ?? null;
}

onMounted(async () => {
  try {
    if (isEdit.value && categoryId.value !== null) {
      const c = await getCategory(categoryId.value);
      setForm(c);
    }
  } catch (e: any) {
    error.value = e?.message || "No se pudo cargar la categoría.";
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
      name: name.value,
      description: description.value,
      discount: discount.value,
    };

    if (isEdit.value && categoryId.value !== null) {
      await updateCategory(categoryId.value, payload);
    } else {
      await createCategory(payload);
    }
    router.push({ name: "categories-index" });
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
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">{{ title }}</h1>
      <button
        type="button"
        class="border rounded px-3 py-1 hover:bg-gray-50"
        @click="$router.push({ name: 'categories-index' })"
      >
        Volver
      </button>
    </div>

    <div v-if="loadingInit" class="text-sm text-gray-500 mb-4">Cargando…</div>

    <div
      v-if="error"
      class="mb-4 bg-red-50 text-red-700 rounded px-3 py-2 text-sm whitespace-pre-line"
    >
      {{ error }}
    </div>

    <form v-if="!loadingInit" @submit.prevent="submit" class="space-y-4 bg-white rounded-2xl p-4 shadow-sm border">
      <div>
        <label class="block text-sm text-gray-600 mb-1">Nombre</label>
        <input
          v-model="name"
          type="text"
          class="w-full border rounded-lg px-3 py-2"
          placeholder="Bebidas"
          required
        />
      </div>

      <div>
        <label class="block text-sm text-gray-600 mb-1">Descripción</label>
        <textarea
          v-model="description"
          rows="3"
          class="w-full border rounded-lg px-3 py-2"
          placeholder="Descripción de la categoría"
        />
      </div>

      <div>
        <label class="block text-sm text-gray-600 mb-1">Descuento (%)</label>
        <input
          v-model.number="discount"
          type="number"
          min="0"
          max="100"
          step="1"
          class="w-full border rounded-lg px-3 py-2"
          placeholder="0 - 100"
        /> 
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
