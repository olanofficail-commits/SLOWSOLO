export const LOCALES = ['lo', 'th', 'en'] as const;
export type Locale = typeof LOCALES[number];

export const DEFAULT_STORE_LOCALE: Locale = 'lo';
export const DEFAULT_ADMIN_LOCALE: Locale = 'th';

export type LocalizedText = {
  lo?: string;
  th?: string;
  en?: string;
};

export function getLocalizedText(textObj?: LocalizedText | null, targetLocale: Locale = DEFAULT_STORE_LOCALE): string {
  if (!textObj) return '';
  if (textObj[targetLocale]) return textObj[targetLocale]!;
  if (textObj.lo) return textObj.lo;
  if (textObj.th) return textObj.th;
  if (textObj.en) return textObj.en;
  return '';
}
