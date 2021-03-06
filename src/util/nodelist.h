
#ifndef _UTIL_NODELIST_H_
#define _UTIL_NODELIST_H_

#ifdef __cplusplus
extern "C" {
#endif

struct nl {
	void * node;
	struct nl * next;
};

struct nl * nl_push (struct nl **, void *);
struct nl * nl_insert (struct nl **, void*);
struct nl* nl_insert2 (struct nl **list, void *node,
		int (* cmp) (const void *n1, const void *n2));
void nl_delete (struct nl *);
char nl_compare (const struct nl *list1, const struct nl *list2);

#ifdef __cplusplus // extern C
}
#endif

#endif
