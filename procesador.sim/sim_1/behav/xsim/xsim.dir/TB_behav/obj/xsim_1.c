/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern void execute_49(char*, char *);
extern void execute_317(char*, char *);
extern void execute_54(char*, char *);
extern void execute_61(char*, char *);
extern void execute_67(char*, char *);
extern void execute_74(char*, char *);
extern void execute_244(char*, char *);
extern void execute_316(char*, char *);
extern void execute_56(char*, char *);
extern void execute_57(char*, char *);
extern void execute_65(char*, char *);
extern void execute_66(char*, char *);
extern void execute_69(char*, char *);
extern void execute_70(char*, char *);
extern void execute_72(char*, char *);
extern void execute_73(char*, char *);
extern void execute_85(char*, char *);
extern void execute_86(char*, char *);
extern void execute_93(char*, char *);
extern void execute_94(char*, char *);
extern void execute_224(char*, char *);
extern void execute_225(char*, char *);
extern void execute_97(char*, char *);
extern void execute_98(char*, char *);
extern void execute_92(char*, char *);
extern void execute_227(char*, char *);
extern void execute_228(char*, char *);
extern void execute_236(char*, char *);
extern void execute_237(char*, char *);
extern void execute_246(char*, char *);
extern void execute_247(char*, char *);
extern void execute_255(char*, char *);
extern void execute_256(char*, char *);
extern void execute_258(char*, char *);
extern void execute_259(char*, char *);
extern void execute_270(char*, char *);
extern void execute_271(char*, char *);
extern void execute_288(char*, char *);
extern void execute_289(char*, char *);
extern void execute_303(char*, char *);
extern void transaction_0(char*, char*, unsigned, unsigned, unsigned);
extern void vhdl_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
funcp funcTab[42] = {(funcp)execute_49, (funcp)execute_317, (funcp)execute_54, (funcp)execute_61, (funcp)execute_67, (funcp)execute_74, (funcp)execute_244, (funcp)execute_316, (funcp)execute_56, (funcp)execute_57, (funcp)execute_65, (funcp)execute_66, (funcp)execute_69, (funcp)execute_70, (funcp)execute_72, (funcp)execute_73, (funcp)execute_85, (funcp)execute_86, (funcp)execute_93, (funcp)execute_94, (funcp)execute_224, (funcp)execute_225, (funcp)execute_97, (funcp)execute_98, (funcp)execute_92, (funcp)execute_227, (funcp)execute_228, (funcp)execute_236, (funcp)execute_237, (funcp)execute_246, (funcp)execute_247, (funcp)execute_255, (funcp)execute_256, (funcp)execute_258, (funcp)execute_259, (funcp)execute_270, (funcp)execute_271, (funcp)execute_288, (funcp)execute_289, (funcp)execute_303, (funcp)transaction_0, (funcp)vhdl_transfunc_eventcallback};
const int NumRelocateId= 42;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/TB_behav/xsim.reloc",  (void **)funcTab, 42);
	iki_vhdl_file_variable_register(dp + 150080);
	iki_vhdl_file_variable_register(dp + 150136);


	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/TB_behav/xsim.reloc");
}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/TB_behav/xsim.reloc");
	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net
	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstatiate();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/TB_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/TB_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/TB_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
