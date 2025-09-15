<script setup lang="ts">
import { ref } from "vue";
import { useRouter, RouterLink } from "vue-router";
import { useAuth } from "@/stores/auth";
import { useFormErrors } from "@/composables/useFormErrors";
import FormError from "@/components/FormError.vue";

const email = ref("");
const password = ref("");
const confirm  = ref("");
const loading  = ref(false);

const { fieldErrors, generalError, firstError, clearErrors, setErrorsFromAxios } = useFormErrors();

const auth = useAuth();
const router = useRouter();

async function submit() {
  clearErrors();

  if (password.value !== confirm.value) {
    (fieldErrors.value.password ||= []).push("Las contraseñas no coinciden");
    return;
  }

  loading.value = true;
  try {
    await auth.register(email.value, password.value);
    router.push({ path: "/login", query: { registered: "1" } });
  } catch (e: any) {
    setErrorsFromAxios(e);
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="w-full max-w-md bg-white shadow-lg rounded-2xl p-8">
      <h1 class="text-2xl font-semibold text-gray-800 mb-6 text-center">Crear cuenta</h1>

      <!-- Error general -->
      <div v-if="generalError" class="mb-4 rounded-lg bg-red-50 text-red-700 px-3 py-2 text-sm whitespace-pre-line">
        {{ generalError }}
      </div>

      <form @submit.prevent="submit" class="space-y-4">
        <div>
          <input
            v-model="email"
            type="email"
            placeholder="Email"
            class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <FormError :message="firstError('email')" />
        </div>

        <div>
          <input
            v-model="password"
            type="password"
            placeholder="Contraseña"
            class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <FormError :message="firstError('password')" />
        </div>

        <div>
          <input
            v-model="confirm"
            type="password"
            placeholder="Confirmar contraseña"
            class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <FormError :message="firstError('password_confirmation')" />
        </div>

        <button
          :disabled="loading"
          class="w-full bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white font-medium py-2.5 rounded-lg transition"
        >
          {{ loading ? "Creando..." : "Crear cuenta" }}
        </button>
      </form>

      <p class="text-center text-sm text-gray-600 mt-6">
        ¿Ya tienes cuenta?
        <RouterLink to="/login" class="text-indigo-600 hover:underline font-medium">Inicia sesión</RouterLink>
      </p>
    </div>
  </div>
</template>
