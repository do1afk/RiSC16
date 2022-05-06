// RiSC Simulator sim03.c
// reads memory from file ram1.txt 
// simulates until HALT 
// each instruction is protocolled to terminal
// writes memory to ram2.txt and writes register dump to terminal
// last update 19.3.19 register dump
// ISA02 BEQ durch BNE ersetzt!!!
// 30.3.20 add_unsigned Befehl für add und addi
// 03.04.22 Arndt Karger: Aufruf von ram1.txt durch Übergabe einer Arbeitsspeicherdatei <Inputfile.hex> ersetzt
// 12.04.2022 Arndt Karger: Funktion hinzugefügt, die den Stack als txt Datei ausgibt

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define MAX_A 65535

char ram[MAX_A] [4] ;
int pc = 0;
char i_reg[4];
int regfile [8];
int terminate_sim=0;

char RAM_NAME [100];




void read_ram(char ram[MAX_A][4] ){

    FILE *ram1;
    int temp,i,j;

    ram1 = fopen(RAM_NAME, "r");

    for (i = 0; i < MAX_A-1; i++) //init ram
       for (j = 0; j <4; j++)
          ram[i][j] = '0'; 

    if(ram1 == NULL) {   //read file into ram
	    printf("Eingabedatei konnte NICHT geoeffnet werden.\n");
    }else { j = 0; i = 0;
           while((temp = fgetc(ram1))!=EOF) {
              ram[j][i] = temp;
              if (i == 3) { i = 0 ; j++; temp = fgetc(ram1);
              } else i++;
          }//while not eof
     } //else
	 fclose(ram1);
     }//read_ram




void write_ram( char ram[MAX_A][4] ){

   FILE *ram2;
   int j;

   ram2 = fopen("ram2.txt", "w");

   if(ram2 == NULL) {
	   printf("Datei 2 konnte NICHT geoeffnet werden.\n");
   }else {
       for (j = 0; j < 256; j++){     //war 256
           fputc(ram[j][0], ram2);
           fputc(ram[j][1], ram2);
           fputc(ram[j][2], ram2);
           fputc(ram[j][3], ram2);
           fputc('\n',ram2);
       }
   }
   fclose(ram2);
}//write ram

void write_stack( char ram[MAX_A][4] ){

   FILE *ram2;
   int j;

   ram2 = fopen("stack2.txt", "w");

   if(ram2 == NULL) {
	   printf("Datei 2 konnte NICHT geoeffnet werden.\n");
   }else {
       for (j = 32703; j < 32768; j++){     
           fputc(ram[j][0], ram2);
           fputc(ram[j][1], ram2);
           fputc(ram[j][2], ram2);
           fputc(ram[j][3], ram2);
           fputc('\n',ram2);
       }
   }
   fclose(ram2);
}//write Stack



int char2hex (char cc) {

   if ((cc>=97)&&(cc<=102)){
	return (cc-87);}
   else if ((cc>=48)&&(cc<=57)){
    return (cc-48);}
   else printf("ERROR NO HEX: %c\n", cc);
}


void dump_regfile (int regfile[8]) {

     int i;

     printf("register dump\nReg     hex     dez\n");
     for ( i=0; i < 8; i++ ){
       printf("R%d   %4x     %4d\n",i,regfile[i],regfile[i]);
     }
}



char hex2char(int i){
	if ((i>=10)&&(i<=15)){
		return (i+87);}
	else if ((i>=0)&&(i<=9)){
		return (i+48);}
    else printf("ERROR NO HEX: %d\n", i);
    }//hex2char




int add_unsigned (int a, int b){
/* add 16bit 2knumbers */

	int i;

	i = a + b;
	return i & (0xffff);               /* eliminate extra bit */

    } //add_unsigned





int add2k (int a, int b){
/* add 16bit 2knumbers */

	int i,j;

	i = a & 0x8000;     /* select sign bit */
	a = a | (i << 1);   /* duplicate sign bit */ 
	i = b & 0x8000;     /* for b: */
	b = b | (i << 1);   /* duplicate sign bit */
	i = a + b;
 
	if ((i & 0x10000) != (i & 0x8000)) { /* different extra bits */
		j = (i & 0x10000) >> 1;    /* extra bit is new sign bit */
		i = i & 0x7fff;            /* sign bit is 0 */
		i = i | j;}                /*set correct sign bit */
	return i & (0xffff);               /* eliminate extra bit */
    } //add2k




int get_ra (int ir0, int ir1){ 
/* gets the first two hex from IR and returns Ra */

	int i0, i1;

	i0=char2hex(ir0);
	i1=char2hex(ir1);
	i0 = (i0 & 1) << 2;  /* select last bit of i0 and shift left 2 positions */
	i1 = (i1 & 12) >> 2; /* select first 2 bits of i1 and shift right 2 positions*/
	return (i0 + i1); /* register a */
	} //get_ra




int get_rb (int ir1, int ir2){
/* gets hex 2 and 3 from IR and returns Rb */

	int i1,i2;

	i1=char2hex(ir1);
	i2=char2hex(ir2);
	i1 = (i1 & 3) << 1;   /* select last 2 bits and shift left 1 pos. */
	i2 = (i2 & 8) >> 3;   /* select first bit and shift right 3 pos. */
	return (i1 | i2);  /* register b */
	} //get_rb




int get_rc (int ir3){
/* for RRR-Instruction: get regc from IR[3] */

	return (char2hex(ir3) & 7);
 	} //get_rc




int get_immediate7 (int ir2, int ir3){

	int i2, i3;

	i2=char2hex(ir2);
	i3=char2hex(ir3);
	i2 = i2 & 7;      /* select last 3 bits all other 0 */
	i2 = i2*16 + i3;  /* offset in 2k - 7 bit*/
	i3 = i2 & 64;    /* select first bit = sign */
	if (i3 == 64) {         /* i3 negative */
    		i2 = i2 & 63;   /* mask last 6 bits */
		i2 = i2 ^ 63;   /* invert all bits */
		i2 = -(i2 + 1); /* add 1 to get abs and make negative */
		}
	else {  /* i3 positive */
		i2 = i2 & 63;  /* select first 6 bits */
		}
	return i2;
	} //get_immediate7




void add ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int ra, rb, rc;
	int tmpb, tmpc;

 	ra = get_ra(i_reg[0], i_reg[1]);
	rb = get_rb(i_reg[1], i_reg[2]);
	rc = get_rc(i_reg[3]);
	tmpb = regfile[rb];
	tmpc = regfile[rc];

	if ((ra > 0) && (ra < 8)) {
		regfile[ra] = add_unsigned(regfile[rb],regfile[rc]); }
	printf("ADD    R%d R%d R%d \t regA: %x regB: %x regC: %x \n",ra,rb,rc,regfile[ra], tmpb, tmpc);
	} /* add */




void add_immediate ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int i0, i1, i2;
	int tmpb;

	i0 = get_ra(i_reg[0], i_reg[1]);
	i1 = get_rb(i_reg[1], i_reg[2]);
	i2 = get_immediate7(i_reg[2], i_reg[3]);
	tmpb = regfile[i1];
	if ((i0 > 0) && (i0 < 8)) {regfile[i0] = add_unsigned(regfile[i1],i2);}
	printf("ADDI   R%d R%d %d \t regA: %x   regB: %x\n",i0, i1, i2, regfile[i0], tmpb);
	} /* add immediate */




void nand ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int ra, rb, rc;
	int tmpb, tmpc;  /* für Testausgabe in einer Zeile, da evtl. Reg.inhalt überschrieben */

 	ra = get_ra(i_reg[0], i_reg[1]);
	rb = get_rb(i_reg[1], i_reg[2]);
	rc = get_rc(i_reg[3]);

	tmpb = regfile[rb];
	tmpc = regfile[rc];

	if ((ra > 0) && (ra < 8)) {
		regfile[ra] = (~(regfile[rb]&regfile[rc])) & 0xffff; }
	printf("NAND R%d R%d R%d \t regA: %x  regB: %x  regC: %x \n",
                ra,rb,rc,regfile[ra],tmpb,tmpc);
	} /* nand */




void load_upper_immediate ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int ra, imm10;

 	ra = get_ra(i_reg[0], i_reg[1]);
	imm10 = ((char2hex(i_reg[1]) & 3) << 8 | char2hex(i_reg[2]) << 4 | 
              char2hex(i_reg[3])) & 0x3ff;
	printf("LUI R%d %x ", ra, imm10);
	if ((ra > 0) && (ra < 8)) { regfile[ra] = (imm10<<6);}
	printf("\t reg A:  %d    0x%4x \n", regfile[ra], regfile[ra]);
	}//load_upper_immediate




void load_word ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int i0, i1, i2, i3;

	i0 = get_ra(i_reg[0], i_reg[1]);
	i1 = get_rb(i_reg[1], i_reg[2]);
	i2 = get_immediate7(i_reg[2], i_reg[3]);
	i3 = regfile[i1] + i2; /* memory adress */	

	printf("LOAD   R%d R%d %d \t RAM adress %d   RAM content %c%c%c%c  \n",
		    i0, i1, i2, i3, ram[i3][0],ram[i3][1],ram[i3][2],ram[i3][3]);
		if ((i0 > 0) && (i0 < 8)) {
			regfile[i0] = char2hex(ram[i3][0])*16*16*16 + char2hex(ram[i3][1])*16*16 
			+ char2hex(ram[i3][2])*16 + char2hex(ram[i3][3]); }
	} /* load_word */




void store_word ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int i0, i1, i2, i3;

	i0 = get_ra(i_reg[0], i_reg[1]);
	i1 = get_rb(i_reg[1], i_reg[2]);
	i2 = get_immediate7(i_reg[2], i_reg[3]);
	i3 = regfile[i1] + i2; /* memory adress */	

	printf("STORE  R%d R%d %d  \t RAM adress %d   REG content %x  \n",
		    i0, i1, i2, i3, regfile[i0]);

	ram[i3][0] = hex2char((0xf000 & regfile[i0]) >> 12);
	ram[i3][1] = hex2char((0x0f00 & regfile[i0]) >> 8);
	ram[i3][2] = hex2char((0x00f0 & regfile[i0]) >> 4);
	ram[i3][3] = hex2char((0x000f & regfile[i0]));
	} /* store_word */




void branch_if_not_equal (char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int ra, rb, imm7;

 	ra = get_ra(i_reg[0], i_reg[1]);
	rb = get_rb(i_reg[1], i_reg[2]);
	imm7 = get_immediate7(i_reg[2], i_reg[3]);

	if (regfile[ra]!=regfile[rb]){
		pc = pc + imm7;
		}
	printf("BNE   R%d R%d %2x \t regA:%d  regB: %d PC: %d\n",
                  ra, rb, imm7, regfile[ra], regfile[rb], pc);
	}//branch_if_not_equal




void jump_and_link (char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

	int ra, rb, exc7;

 	ra = get_ra(i_reg[0], i_reg[1]);
	rb = get_rb(i_reg[1], i_reg[2]);
	exc7 = ((char2hex(i_reg[2])&7) << 4 ) | ( char2hex(i_reg[3]) );	
	if (exc7 == 0){
			if ((ra > 0) && (ra < 8)) {
				regfile[ra] = pc;
				pc = regfile[rb];
				}
			}
	else { terminate_sim = 1; }
	printf("JALR   R%d R%d %2x \t regB: %d\n",ra, rb, exc7, regfile[rb] );
	} // jump_and_link




void one_step ( char ram[MAX_A][4], char i_reg[4], int regfile[8] ){

     int i,j;
	 /* start: get instruction from memory */
     if ((pc >= 0) && (pc <= MAX_A)) {

	for ( i=0; i < 4; i++ ) {
          i_reg[i] = ram[pc][i];
          };
	printf("PC %d \t IR: %c %c %c %c \t",pc, i_reg[0],i_reg[1],i_reg[2],i_reg[3]);
     }
    else {

     	printf("illegal address ... terminate\n");
     	terminate_sim = 1;
     } 
    
     pc++; /* increment program counter */
    
    
     switch(i_reg[0]) {   /* decode instruction and branch into execution */

	case ('0'): ;
	case ('1'): add	(ram, i_reg,regfile);
				break;
	case ('2'): ;
 	case ('3'): add_immediate (ram, i_reg,regfile);
				break;
	case ('4'): ;
	case ('5'): nand (ram, i_reg,regfile);
				break;
	case ('6'): ;
	case ('7'): load_upper_immediate(ram, i_reg,regfile);
				break;
	case ('8'): ;
	case ('9'): store_word(ram, i_reg,regfile);
				break;
	case ('a'): ;
	case ('b'): load_word(ram, i_reg,regfile);
				break;
	case ('c'): ;
 	case ('d'): branch_if_not_equal (ram, i_reg,regfile);
				break;
	case ('e'): ;
	case ('f'): jump_and_link (ram, i_reg,regfile);
				break;
	default: printf("instruction error\n");
  	}
     
} /* one_step */



int main(int argc, char *argv[]){

	int i; /* test only*/
	
	
//Überprüfe Übergabe
    
    
    
    if(argc < 2) // Input file übergeben?
        {
        printf("\nNo Input File\nUsage: ./RiSC16SIM_Arndt <Inputfile.hex> \nExiting!\n");
        exit(1); 
        }
        
    int length = strlen(argv[1]);   //ermittle Länge des strings und finde raus, ob das zu lang ist
    if(length>99)  
        {
        printf("\nInputfile name too long! \nExiting!\n");
        exit(1); 
        }
        
       
    strcpy(RAM_NAME, argv[1]);  //eingebene Datei in globaler Variable speichern
    

   for(int i = 0; i<4; i++) //Überprüfe Dateiendung
    {
        char ending [5] = ".hex";        
                
        if(ending[i] != RAM_NAME[length-(4-i)])
        {
            printf("\nInputfile is not a <.hex>! \nExiting!\n");
            exit(1);
        }
    }
     

	read_ram(ram);

	do { one_step(ram,i_reg,regfile); }
		while (terminate_sim == 0);
	
	write_ram(ram);
    write_stack(ram);

    dump_regfile(regfile);
}
