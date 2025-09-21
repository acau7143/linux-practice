# 포인터 변수와 stack/heap 메모리 분석


# 포인터

```
변수  == 메모리 공간 "무엇이 들어가는가?"

일반 변수 <= 일반 값 ( 예 : int, double, char, float, .. )
포인터변수 <= (일반 변수의)주소 값 ( 예 : int*, char* )
이중포인터변수 <= (포인터변수의)주소 값

CPU -> 32bit ( 가상주소 : 4 바이트 )
CPU -> 64bit ( 가상주소 : 8 바이트 )
```

```c
int a = 1;
int b = 2;
int *p, *p1;
int **p;
(변수 : 방) = ( 값 or 방의 값 )

*(주소) => 그 주소에 해당되는 방과 동일한 효과
p = &a;
b = *p;  // *p는 a방과 동일한 효과
*p = 10;  // *p는 a방과 동일한 효과

pp = &p;
p1 = *pp; // *pp는 p방과 동일한 효과
				  // p방은 a의 방(주소)과 동일 일반 변수 주소를 받을려면 포인터가 받아야 함
*pp = &b; 
 a = **pp; // *pp는 p방과 동잏한 효과  -> *p는 b 방과 동일한 효과
 
**pp = 100;   
```

```c
  1 #include <stdio.h>
  2 #include <stdlib.h>
  3
  4 struct contact_info {
  5         char *name;
  6         char *phone_number;
  7         struct contact_info *next;
  8 };
  9
 10
 11 void insert(struct contact_info **head)
 12 {
 13     struct contact_info *new_node = (struct contact_info *)malloc(sizeof(struct contact_info));
 14
 15     printf("\n(2) Start insert(&contact_head);\n");
 16
 17     printf("'new_node' variable address(stack) : %p\n", &new_node);
 18     printf("'new_node' variable data(heap) : %p\n", new_node);
 19
 20     *head = new_node;
 21
 22     printf("'head' variable address(stack) : %p\n", &head);
 23     printf("'head' variable data: %p\n", head);
 24     printf("'contact_head' variable data: %p\n", *head);
 25
 26     printf("\n(3) End insert(&contact_head);\n");
 27 }
 28
 29 void main()
 30 {
 31     /* head node for contacts list */
 32         struct contact_info *contact_head = NULL;
 33     int a = 1;
 34
 35     printf("'a' variable address(stack) : %p\n", &a);
 36     printf("'a' variable data: %d\n", a);
 37
 38     printf("\n(1) Before insert(&contact_head);\n");
 39     printf("'contact_head' variable address(stack) : %p\n", &contact_head);
 40     printf("'contact_head' a variable data: %p\n", contact_head);
 41
 42     insert(&contact_head);
 43
 44     printf("\n(4) After insert(&contact_head);\n");
 45     printf("'contact_head' variable address(stack) : %p\n", &contact_head);
 46     printf("'contact_head' a variable data: %p\n", contact_head);
 47
 48 }

```

- *`head`를 출력 → **contact_head “변수의 주소”**(스택 주소)가 나온다. (예: `0x7ff...`)
- `head`를 출력 → **contact_head “값”** = 새 노드의 주소(힙 주소)가 나온다. (예: `0x555...`)
- `&head`를 출력 → **insert 함수 안의 `head` 지역변수 주소**(스택 주소, `head`와는 다른 값)가 나온다.
