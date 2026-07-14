/**
 * Convert a simple glob string into an anchored RegExp.
 *
 * Supported wildcards:
 *   *  -> matches any run of characters (including none)
 *   ?  -> matches exactly one character
 *
 * Everything else is treated literally (regex metachars are escaped).
 */
export function globToRegExp(glob: string): RegExp {
	const escaped = glob.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
	const pattern = escaped.replace(/\\\*/g, ".*").replace(/\\\?/g, ".");
	return new RegExp(`^${pattern}$`);
}

/** True if `subject` matches the glob (after anchoring). */
export function globMatches(glob: string, subject: string): boolean {
	return globToRegExp(glob).test(subject);
}
