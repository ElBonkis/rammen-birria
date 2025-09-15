<script setup lang="ts">
import { ref, watch, onMounted } from "vue";
import { fetchCategories, type Category } from "@/api/categories";

const props = defineProps<{
  modelValue: number | null;
}>();
const emit = defineEmits<{
  (e: "update:modelValue", v: number | null): void;
}>();

const categories = ref<Category[]>([]);
const loading = ref(true);
const error = ref("");

onMounted(async () => {
  try {
    categories.value = await fetchCategories();
  } catch (e: any) {
    error.value = e?.message || "No se pudieron cargar las categorías.";
  } finally {
    loading.value = false;
  }
});

function setCategory(id: number | null) {
  emit("update:modelValue", id);
}
</script>

<template>
  <div class="w-full border-b bg-white">
    <div class="max-w-6xl mx-auto px-4 py-3 flex items-center gap-2 overflow-x-auto">
      <button
        class="px-3 py-1.5 text-sm rounded-full border transition"
        :class="[
          props.modelValue === null
            ? 'bg-indigo-600 text-white border-indigo-600'
            : 'hover:bg-gray-50'
        ]"
        @click="setCategory(null)"
      >
        Todas
      </button>

      <template v-if="!loading && !error">
        <button
          v-for="c in categories"
          :key="c.id"
          class="px-3 py-1.5 text-sm rounded-full border transition whitespace-nowrap"
          :class="[
            props.modelValue === c.id
              ? 'bg-indigo-600 text-white border-indigo-600'
              : 'hover:bg-gray-50'
          ]"
          @click="setCategory(c.id)"
        >
          {{ c.name }}
        </button>
      </template>

      <span v-if="loading" class="text-xs text-gray-500">Cargando categorías…</span>
      <span v-if="error" class="text-xs text-red-600">{{ error }}</span>
    </div>
  </div>
</template>
