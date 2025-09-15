import { ref } from "vue";

export type FieldErrors = Record<string, string[]>;

export function useFormErrors() {
  const fieldErrors = ref<FieldErrors>({});
  const generalError = ref("");

  function clearErrors() {
    fieldErrors.value = {};
    generalError.value = "";
  }

  function firstError(key: string): string {
    return fieldErrors.value[key]?.[0] ?? "";
  }

  function setErrorsFromPayload(payload: any) {
    clearErrors();
    const errs = payload?.errors;

    if (Array.isArray(errs)) {
      generalError.value = errs.join("\n");
      return;
    }
    if (errs && typeof errs === "object") {
      fieldErrors.value = errs as FieldErrors;
      return;
    }
    if (typeof payload?.error === "string") {
      generalError.value = payload.error;
      return;
    }
    generalError.value = "Ocurrió un error. Inténtalo nuevamente.";
  }

  function setErrorsFromAxios(error: any) {
    setErrorsFromPayload(error?.response?.data);
  }

  return {
    fieldErrors,
    generalError,
    firstError,
    clearErrors,
    setErrorsFromPayload,
    setErrorsFromAxios,
  };
}
