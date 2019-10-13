/*
 * test3.cxx
 * 
 * DJ (c) 1996
 * 
 * USUAL DISCLAIMER: THIS EXAMPLE IS PROVIDED AS IS 
 * WITH NO WARRANTY FOR ANY PURPOSE.
 */

extern "C"
{	
	extern void DUART_INIT(void);
	extern void DUART_PUTC(char c);
	extern char DUART_GETC(void);
}


/*
 * Function: puts (print a string)
 */
void puts(const char*s)
{
	while(*s) DUART_PUTC(*s++);
}

/*
 * Function main
 */
int main(void)
{
	DUART_INIT();
	puts("Hello world++!\n");
	DUART_GETC();
	puts("Done.\n");
	while(1);	  
	return 0;
}
