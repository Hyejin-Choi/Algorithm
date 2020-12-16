#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#define MEASURE_TIME	// to measure time

 /////////////////////////////////////////////////////////////
 // DATA STRUCTURE:
 // binary tree node definition using doubly linked lists
 // key is a string of a fixed length
 // KEYLENGTH	length of the key
 // BULK_SIZE	key is hidden in the "BULK"
 //	to retrieve key, we have to dig into the "BULK"
 //	so accessing key takes average "BULK_SIZE"/2 searches
 //	this is INTENTIONALLY to add extra overhead for search
 //	your program should reduce the number of key accesses at your best
 /////////////////////////////////////////////////////////////
#define KEYLENGTH	3
#define BULK_SIZE	4096
int W[BULK_SIZE] = {-1,};
int W2[BULK_SIZE] = {-1,};
char* array[BULK_SIZE];
//#define BULK_SIZE	65536
struct BTNode {
	char bulk[BULK_SIZE];
		// null character to be added
		struct BTNode* next;
	struct BTNode *parent,* left, * right;	// binary tree: left and right children
};
//bulk 때문에 overhead가 큼 -> 새로운 것을 만들거나 카피 자제 genertate_btnode를 만들지 마

/////////////////////////////////////////////////////////////
// GIVEN: functions for binary tree node
// name and parameters only
// implementations are moved after "main" function
/////////////////////////////////////////////////////////////

const char* getkey(struct BTNode* a);
// return value: char array of KEYLENGTH+1 (+1 for '\0' character)
//  key is hidden in "bulk", so use the following function to
//  read key string of length KEYLENGTH
//  it will make BULK_SIZE/2 searches on average
//  so try to use it as rarely as possible

int setkey(struct BTNode* a, const char kw[]);
// return value: 0 for failure (NULL a), 1 for success
//  the following function hides a string "kw" of KEYLENGTH
//  by randomly selecting the location to save key

int copykey(struct BTNode* dst, struct BTNode* src)
{
	return setkey(dst, getkey(src));
}
// copies the key of one node to the other
// very simple, single line, so implementation is given here

int comparekey(struct BTNode* a, struct BTNode* b);
// return value: (by character comparison)
//  -1 if a's key < b's key
//  0 if a's key == b's key
//  +1 if a's key > b's key
//  may be needed for binary search tree search and build-up

struct BTNode* generate_btnode(const char kw[]);
// return value: pointer to a single BTNode (left/right are NULL)
//  generates a node for binary tree

void free_bt_recursive(struct BTNode* bt);
// frees a binary tree

struct BTNode* copy_bt_recursive(struct BTNode* bt);
// return value: pointer to the root of the copy of the given binary tree "bt"

struct BTNode* insert_left_bcnode(
	struct BTNode* parent, struct BTNode* newPtr);
//  adds a node to the left of a BTNode parent
//  it will be used to generate a left-half binary tree
//  (LHBT, all rights are NULL)
// pre-condition: left pointer to the new node should be NULL
// to store the left pointer to the parent node
// return value: parent if the given parent is not NULL; newPtr if parent NULL

struct BTNode* readkeys_textfile_LHBT(const char infile[], int* pN);
// File I/O: read key words from the given file
// and generate a binary tree which is left-half
// (all right children are NULL)

/////////////////////////////////////////////////////////////
// FILL 1: generate a binary search tree using insertion
/////////////////////////////////////////////////////////////
struct BTNode* insert_to_BST_leaf(struct BTNode* bst, struct BTNode* newPtr)
{
	if (bst == NULL) return newPtr;	// new bst as the input node
	else if (newPtr == NULL) return bst;	// nothing to add
	else {
		if (comparekey(bst, newPtr) < 0) { //newPtr이 클때
			if (bst->right == NULL) {
				bst->right = newPtr;
			}
			else
				insert_to_BST_leaf(bst->right, newPtr);
		}
		else {

			if (bst->left == NULL) {
				bst->left = newPtr;
			}
			else
				insert_to_BST_leaf(bst->left, newPtr);
		}
	}
	return bst;
}

struct BTNode* generate_BST_by_insertion(FILE *fp,struct BTNode* lhbt)
{
	char* bst_key;
	struct BTNode* BST = NULL;
	struct BTNode* temp_BST2;
	while (lhbt != NULL) {
        temp_BST2 = (struct BTNode*)malloc(sizeof(struct BTNode));
		bst_key = getkey(lhbt);
		setkey(temp_BST2,bst_key); ////error
		temp_BST2->left = temp_BST2->right = NULL;
       // fprintf(fp,"%s",getkey(temp_BST2));
		BST = insert_to_BST_leaf(BST, temp_BST2);
		lhbt = lhbt->left;
	}
	return BST;
	/* FILL */
	/* (hint: use insert_to_BST_leaf repeatedly) */
}

/////////////////////////////////////////////////////////////
// FILL 2: PRINT
/////////////////////////////////////////////////////////////
int print_LHBT(FILE* fp, struct BTNode* lhbt)
// prints left-half binary tree
// ___-___-___
// INPUT
//   fp: file pointer for the output file, stdout for monitor output
//   lhbt: left-half binary tree (right pointers are all null)
// RETURNs number of NODES in the list
{
	int num_nodes;

	num_nodes = 0;
	while (lhbt) {
		if (lhbt->right != NULL) {	// check if left-half
			fprintf(stderr, "Non-left-half binary tree for %s\n", __FUNCTION__);
			break;
		}
		else {
			fprintf(fp, "%s", getkey(lhbt));
			if (lhbt->left != NULL) fprintf(fp, "-");
		}
		num_nodes++;
		lhbt = lhbt->left;
	}

	fprintf(fp, "\n");	// change the line at the end

	return num_nodes;
}

int print_BST_sortedorder(FILE* fp, struct BTNode* root)
{
	struct BTNode* current, * pre;
	int count = 0;
	if (root == NULL)
		return;

	current = root;
	while (current != NULL) {

		if (current->left == NULL) {
			fprintf(fp, "%s ", getkey(current));
			count++;
			current = current->right;
		}
		else {

			pre = current->left;
			while (pre->right != NULL && pre->right != current)
				pre = pre->right;

			if (pre->right == NULL) {
				pre->right = current;
				current = current->left;
			}


			else {
				pre->right = NULL;
				fprintf(fp, "%s ", getkey(current));
				count++;
				current = current->right;
			}
		}
	}
	fprintf(fp,"\n");
	return count;
}
//Find Height ft
int Find_Height(struct BTNode* bst){

 if (bst==NULL)
       return 0;
   else
   {

       int left_height = Find_Height(bst->left);
       int right_height = Find_Height(bst->right);


       if (left_height > right_height)
           return(left_height+1);
       else
        return(right_height+1);
   }
}
int print_BST_right_center_left(FILE* fp, struct BTNode* bst, int level)
{
	char* length ="    ";
	int i;
	if (bst == NULL)
		return;
    level ++;
	print_BST_right_center_left(fp, bst->right, level);

    fprintf(fp,"\n");
	for(i=0;i<level;i++)
	fprintf(fp, "%s",length); //length
	fprintf(fp, "%s", getkey(bst));

	print_BST_right_center_left(fp, bst->left, level);

	return Find_Height(bst);

}

int print_BST_1(FILE* fp, struct BTNode* bst, int level)
{
	char* length = "   ";
	int i;
	if (bst == NULL)
		return;
	level++;
	fprintf(fp, "%s", getkey(bst));
	if (bst->right != NULL) {
		fprintf(fp,"/");
	}
	print_BST_1(fp, bst->right, level);

	if (bst->left != NULL) {
		fprintf(fp,"\n");
		for (i = 0; i <=level;i++) {
		fprintf(fp,"%s",length);
		if(i == level)
			fprintf(fp,"+");
        else
            fprintf(fp," ");
		}
	}

	print_BST_1(fp, bst->left, level);

	return Find_Height(bst);
}

int print_BST_2(FILE* fp, struct BTNode* bst, int level)
{
	char* length = "   ";
	int i;
	if (bst == NULL)
		return;
	level++;

	if (bst->left != NULL && bst->right != NULL){
        W[level] = 1;

	}

	fprintf(fp, "%s", getkey(bst));
	if (bst->right != NULL) {
		fprintf(fp, "/");

	}
	print_BST_2(fp, bst->right, level);

	if (bst->left != NULL) {
		fprintf(fp, "\n");

		for (i = 0; i <= level; i++) {
			fprintf(fp, "%s", length);
			if (i == level){
				fprintf(fp, "+");
                W[level]--;
			}
			else if(W[i] ==1)
				fprintf(fp, "|");
			else
				fprintf(fp, " ");
		}
	}

	print_BST_2(fp, bst->left, level);

	return Find_Height(bst);
}


/////////////////////////////////////////////////////////////
// FILL 3: Conversion of an BST to a complete BST
/////////////////////////////////////////////////////////////
struct BTNode* sorted_order(struct BTNode* root,struct BTNode* node,struct BTNode* list, int numNodes){

struct BTNode* current, * pre;

struct BTNode* list2 = (struct BTNode*)malloc(sizeof(struct BTNode));
	int i= -1 ;
	if (root == NULL)
		return;

	current = root;
	while (current != NULL) {

		if (current->left == NULL) {

			i++;
			array[i] = getkey(current);

			current = current->right;
		}
		else {

			pre = current->left;
			while (pre->right != NULL && pre->right != current)
				pre = pre->right;

			if (pre->right == NULL) {
				pre->right = current;
				current = current->left;
			}


			else {
				pre->right = NULL;

                i++;
                array[i] = getkey(current);

				current = current->right;
			}
		}
	}

	for(i=0,node = list ;node!=NULL;node=node->next,i++)
            setkey(node,getkey(array[i]));
	return list;
}
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

struct BTNode* BST_to_completeBST(struct BTNode* list)
{
    int i, n;
	char h;
	int leaves;
	int depth[32];

	struct BTNode* current;
	struct BTNode root = { 0 };

	// get the length 'n' of the list
	for (n = 0, current = list; current != NULL; current = current->next, n++);
	for (h = 0, i = n + 1; i > 1; i = i >> 1, h++);
	 leaves = n+1  - (1<<h);


	// prepare to start
	if (leaves != 0) h++;
	depth[0] = h + 1;
	depth[1] = 0;
	h = 0;
	current = &root;

	while(list !=NULL)
	{
		while (depth[h] == depth[h + 1] + 1)
		{
			h--;
			current = current->parent;
		}
		depth[++h] = depth[h] + 1;
		depth[h + 1] = 0;

		list->parent = current;
		list->right = NULL;
		list->left = current->right;
		current->right = list;
		current = list;

		if (list->left != NULL)
			list->left->parent = list;


		else if (leaves != 0)
		{
			leaves--;
			if (leaves == 0)
			{
				for (i = 0; i <= h; i++)
                depth[i]--;
				h--;
				current = current->parent;
			}
		}
		list = list->next;

	}

	root.right->parent = NULL;
	return root.right;



}


/////////////////////////////////////////////////////////////
// FILL 4: generate binary search tree from a left-half binary tree
// using quick sort
/////////////////////////////////////////////////////////////
struct BTNode* generate_BST_quicksort_basic(struct BTNode* lhbt,int left,int numNodes)
	// gerate a BST using quick sort algorithm
	// the resultant tree should be identical to generate_BST_by_insertion
{
	struct BTNode* bst = NULL;
	struct BTNode* Pivot;
	char* index;
	while (lhbt!=NULL) {
		Pivot = (struct BTNode*)malloc(sizeof(struct BTNode));
		index = getkey(lhbt);
        setkey(Pivot,index);
		Pivot->left = Pivot->right = NULL;
		Partition(lhbt, left, numNodes);
		bst = insert_to_BST_leaf(bst, Pivot);
		lhbt = lhbt->left;
	}

	return bst;
}
void Partition(struct BTNode* lhbt,int left,int right) {
	char * bst_pivot,bst_pivot2;
    struct BTNode*Pivot;
    struct BTNode*Pivot_Next;
    struct BTNode* bst = NULL;
    Pivot = (struct BTNode*)malloc(sizeof(struct BTNode));
	bst_pivot = getkey(lhbt);
	setkey(Pivot,bst_pivot); //root결정
	Pivot->left = Pivot->right = NULL;
	while(lhbt!= NULL ){
    Pivot_Next = (struct BTNode*)malloc(sizeof(struct BTNode));
	//Pivot_Next->left = Pivot_Next->right = NULL;
	bst_pivot2 = getkey(lhbt);
	setkey(Pivot_Next,bst_pivot2);
	if(comparekey(Pivot,Pivot_Next)<=0) { //Next가 크면 오른쪽 트리로
         insert_to_BST_leaf(bst, Pivot_Next);
	}
	else

        insert_to_BST_leaf(bst, Pivot_Next);

         lhbt = lhbt->left;
	}


}
struct BTNode* generate_BST_quicksort_advanced(struct BTNode* lhbt)
	// challenge: try to reduce the height using quick sort algorithm
{
	/* FILL */
}

/////////////////////////////////////////////////////////////
// main function
/////////////////////////////////////////////////////////////
#define MAXLINE	1024
int main()
{
	int numWords;	// number of words
	//int wordLen;	// word length: number of characters per word
	struct BTNode* root, * bst1, * bst2;
	int numNodes, lev;	// level of the tree

	int i, n = 0;
    struct BTNode* list = NULL;
    struct BTNode* tree;
    struct BTNode* node;
    char* tmp_bst;
	/* for file name, max length 1023 including path */
	char line[MAXLINE];
	char infile[MAXLINE], outfile[MAXLINE];
	FILE* fp;

#ifdef MEASURE_TIME
	clock_t start, end;
	double cpu_time_used;
#endif

	/* input file name given by keyboard */
	memset(line, 0, sizeof(char) * MAXLINE);	// clear the buffer
	fprintf(stderr, "Input file name? ");
	fgets(line, MAXLINE, stdin);
	if (strlen(line) == 0 || sscanf(line, "%s", infile) != 1) {
		fprintf(stderr, "cannot read input file name from '%s'\n", line);
		exit(0);
	}

	/* output file name: enter for standard out */
	memset(line, 0, sizeof(char) * MAXLINE);	// clear the buffer
	fprintf(stderr, "Output file name? ");
	fgets(line, MAXLINE, stdin);char* array[BULK_SIZE];
	if (strlen(line) == 0 || sscanf(line, "%s", outfile) != 1) {
		fprintf(stderr, "cannot read output file name from '%s'\n", line);
		fprintf(stderr, "output to stdout\n");
		fp = stdout;
		memset(outfile, 0, sizeof(char) * MAXLINE);	// clear the buffer
	}
	else {
		/* open output file pointer */
		fp = fopen(outfile, "w");
		if (fp == NULL) {
			fprintf(stderr, "cannot open file '%s' for write\n", outfile);
			fprintf(stderr, "output to stdout\n");
			fp = stdout;
		}
	}

	/* read text file of integers:
	 * number_of_intergers integer1 integer2 ...
	 * then convert it to a linked list */
	root = readkeys_textfile_LHBT(infile, &numWords);

#ifdef MEASURE_TIME
	start = clock();
#endif

	if (root != NULL) {

		// prints input
		fprintf(fp, "=====================================\n");
		numNodes = print_LHBT(fp, root);
		fprintf(fp, "total %d nodes\n", numNodes);

		// BST construction by simple insertion
		// keep root unchanged
		bst1 = generate_BST_by_insertion(fp,copy_bt_recursive(root));

		fprintf(fp, "=====================================\n");
		numNodes =print_BST_sortedorder(fp, bst1);
		fprintf(fp, "total %d nodes (sorted)\n", numNodes);
		fprintf(fp, "=====================================");
		lev = print_BST_right_center_left(fp, bst1,-1);
		fprintf(fp, "\nBST height %d\n", lev);
		fprintf(fp, "=====================================\n");
		lev = print_BST_1(fp, bst1, -1);
		fprintf(fp, "\nBST height %d\n", lev);
		fprintf(fp, "=====================================\n");
		lev = print_BST_2(fp, bst1, -1);
		fprintf(fp, "\nBST height %d\n", lev);
		fprintf(fp, "=====================================\n");
////////////////////////////////////////////////////////////////////////////////////////////
		//completeBST
		n = numNodes;
		list = (struct BTNode*)realloc(list, n * sizeof(struct BTNode));
       // node = (Node*)realloc(list, n * sizeof(Node));
            for (i = 0; i < n - 1; i++)
			list[i].next = &list[i + 1];
            list[n - 1].next = NULL;

            list = sorted_order(bst1,node,list,numNodes);

		tree = BST_to_completeBST(list);
        //lev = Find_Height(tree);
		lev = print_BST_2(fp, tree, -1);
		fprintf(fp, "\nComplete BST height %d\n", lev);
		fprintf(fp, "=====================================\n");


		// BST using quick sort, pivot as left, basic
		bst2 = generate_BST_quicksort_basic(copy_bt_recursive(root),1,numNodes);
		lev = print_BST_2(fp, bst2, -1);
		fprintf(fp, "\nBST by QUICKSORT, height %d\n", lev);
		fprintf(fp, "=====================================\n");

		// BST using quick sort, advanced, to reduce height
		//bst2 = generate_BST_quicksort_advanced(copy_bt_recursive(root));
		//lev = print_BST_2(fp, bst2, -1);
		//fprintf(fp, "\nBST by QUICKSORT (advanced), height %d\n", lev);
		//fprintf(fp, "=====================================\n");

		free_bt_recursive(root);
		free_bt_recursive(bst1);
		free_bt_recursive(bst2);
	}

#ifdef MEASURE_TIME
	end = clock();
	cpu_time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
	fprintf(fp, "TIME %.5f seconds\n", cpu_time_used);
#endif

	if (fp != NULL && fp != stdout) fclose(fp);
	return 0;
}


/////////////////////////////////////////////////////////////
// implementation: functions for binary tree node
/////////////////////////////////////////////////////////////




const char* getkey(struct BTNode* a)
{
	int i;
	for (i = 0; i < BULK_SIZE - KEYLENGTH; i++) {
		if (a->bulk[i] != '\0') return a->bulk + i;
	}
	return NULL;	// not found
}




int setkey(struct BTNode* a, const char kw[])
{
	int pos;
	if (a != NULL) {
		// fill with 0
		memset(a->bulk, 0, sizeof(char) * BULK_SIZE);

		// find position randomly to store KEYLENGTH+1 characters
		pos = rand() % (BULK_SIZE - KEYLENGTH);
		if (kw != NULL) memcpy(a->bulk + pos, kw, sizeof(char) * KEYLENGTH);
		a->bulk[pos + KEYLENGTH] = '\0';	// to make it a C string

		// success
		return 1;
	}
	else return 0;
}

struct BTNode* generate_btnode(const char kw[])
{
	struct BTNode* tmp;

	tmp = (struct BTNode*)malloc(sizeof(struct BTNode));
	setkey(tmp, kw);

	// initial left and right children for the generated leaf node
	tmp->left = tmp->right = NULL;

	return tmp;
}

void free_bt_recursive(struct BTNode* bt)
{
	if (bt != NULL) {
		free_bt_recursive(bt->left);
		free_bt_recursive(bt->right);
		free(bt);
	}
}

struct BTNode* copy_bt_recursive(struct BTNode* bt)
{
	struct BTNode* dup;

	if (bt != NULL) {
		dup = (struct BTNode*) malloc(sizeof(struct BTNode));
		copykey(dup, bt);
		dup->left = copy_bt_recursive(bt->left);
		dup->right = copy_bt_recursive(bt->right);
	}
	else dup = NULL;
	return dup;
}

struct BTNode* insert_left_bcnode(struct BTNode* parent, struct BTNode* newPtr)
{
	if (parent == NULL) return newPtr;	// no parent
	else if (newPtr == NULL) return parent;	// Nothing to add
	else if (newPtr->left != NULL) {
		fprintf(stderr, "cannot add a node with non-null left tree\n");
		return parent;
	}
	else {
		newPtr->left = parent->left;
		parent->left = newPtr;
		return newPtr;	// returning new node as a new parent
	}
}

// static: internal use only
static int _compare_n_char(const char a[], const char b[], int L)
{
	int i;
	for (i = 0; i < L; i++) {
		if (a[i] < b[i]) return -1;
		else if (a[i] > b[i]) return 1;
		else continue;	// to next character
	}
	return 0;
}

int comparekey(struct BTNode* a, struct BTNode* b)
{
	return _compare_n_char(getkey(a), getkey(b), KEYLENGTH);
}

/////////////////////////////////////////////////////////////
// File I/O
/////////////////////////////////////////////////////////////
struct BTNode* readkeys_textfile_LHBT(const char infile[], int* pN)
	// read key words from the given file
	// and generate a binary tree which is skewed to the left
	// (all right children are NULL)
{
	struct BTNode* root, * cur, * tmp;
	char word[1024];
	FILE* fp;
	int i;

	// check for input file name
	if (infile == NULL) {
		fprintf(stderr, "NULL file name\n");
		return NULL;
	}

	// check for file existence
	fp = fopen(infile, "r");
	if (!fp) {
		fprintf(stderr, "cannot open file %s\n", infile);
		return NULL;
	}

	// check for number of keys
	if (fscanf(fp, "%d", pN) != 1 || *pN <= 0) {
		fprintf(stderr, "File %s: ", infile);
		fprintf(stderr, "number of keys cannot be read or or wrong\n");
		fclose(fp);
		return NULL;
	}

	/*
	// check for number of characters per key
	if ( fscanf(fp, "%d", pL) != 1 || *pL <= 0 ) {
	  fprintf(stderr, "File %s: ",infile);
	  fprintf(stderr, "number of characters per key cannot be read or or wrong\n");
	  fclose(fp);
	  return NULL;
	}
	*/

	// reading keys
	root = cur = tmp = NULL;
	for (i = 0; i < (*pN); i++) {
		if (fscanf(fp, "%s", word) != 1) {
			fprintf(stderr, "cannot read a word at %d/%d\n", i + 1, (*pN));
			*pN = i;	// number of read keys so far
			break;
		}
		else {
			//check_and_correct_word(word, KEYLENGTH);

			// generate a new node
			tmp = generate_btnode(word);

			if (root == NULL) root = cur = tmp;
			else cur = insert_left_bcnode(cur, tmp);
		}
	}

	return root;
}
