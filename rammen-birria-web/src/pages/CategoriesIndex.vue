<script setup lang="ts">
import { onMounted, ref } from "vue";
import AppTopBar from "@/components/AppTopBar.vue";
import { fetchCategories, type Category } from "@/api/categories";

const categories = ref<Category[]>([]);
const loading = ref(true);
const error = ref("");

onMounted(async () => {
  try { categories.value = await fetchCategories(); }
  catch (e:any) { error.value = e?.message || "No se pudieron cargar las categorías."; }
  finally { loading.value = false; }
});
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <AppTopBar />
    <div class="max-w-6xl mx-auto p-4 md:p-6">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-bold">Categorías</h1>
        <RouterLink :to="{ name: 'categories-new' }" class="bg-indigo-600 text-white rounded px-3 py-2 text-sm">
          Nueva categoría
        </RouterLink>
      </div>

      <div v-if="error" class="mb-4 bg-red-50 text-red-700 rounded px-3 py-2 text-sm">{{ error }}</div>
      <div v-else-if="loading" class="text-sm text-gray-500">Cargando…</div>

      <ul v-else class="space-y-2">
        <li v-for="c in categories" :key="c.id" class="bg-white border rounded-lg p-3 flex items-center justify-between">
          <span class="font-medium">{{ c.name }}</span>
          <div class="flex gap-2">
            <RouterLink :to="{ name: 'categories-edit', params: { id: c.id } }" class="border rounded px-3 py-1 text-sm">Editar</RouterLink>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
