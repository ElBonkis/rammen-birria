<script setup lang="ts">
import { ref } from "vue";
import { RouterLink } from "vue-router";
import { useAuth } from "@/stores/auth";
import { useFormErrors } from "@/composables/useFormErrors";

const email = ref("");
const loading = ref(false);
const sent = ref(false);

const { generalError, clearErrors, setErrorsFromAxios } = useFormErrors();
const auth = useAuth();

async function submit() {
  clearErrors(); sent.value = false; loading.value = true;
  try {
    await auth.requestPasswordReset(email.value);
    sent.value = true;
  } catch (e:any) {
    setErrorsFromAxios(e);
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="w-full max-w-md bg-white shadow-lg rounded-2xl p-8">
      <h1 class="text-2xl font-semibold text-center mb-4">Recuperar contraseña</h1>

      <div v-if="generalError" class="mb-3 rounded bg-red-50 text-red-700 px-3 py-2 text-sm">
        {{ generalError }}
      </div>
      <div v-if="sent" class="mb-3 rounded bg-green-100 text-green-800 px-3 py-2 text-sm">
        Si el correo existe, te enviamos un enlace para restablecerla.
      </div>

      <form @submit.prevent="submit" class="space-y-4">
        <input v-model="email" type="email" placeholder="Tu correo"
               class="w-full rounded-lg border px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500" />
        <button :disabled="loading" class="w-full bg-indigo-600 text-white rounded-lg py-2.5">
          {{ loading ? "Enviando..." : "Enviar enlace" }}
        </button>
      </form>

      <p class="text-center text-sm text-gray-600 mt-6">
        <RouterLink to="/login" class="text-indigo-600 hover:underline">Volver al inicio de sesión</RouterLink>
      </p>
    </div>
  </div>
</template>
