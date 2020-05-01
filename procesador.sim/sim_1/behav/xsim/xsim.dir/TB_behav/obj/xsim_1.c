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
extern void execute_64(char*, char *);
extern void execute_395(char*, char *);
extern void execute_82(char*, char *);
extern void execute_83(char*, char *);
extern void execute_90(char*, char *);
extern void execute_102(char*, char *);
extern void execute_109(char*, char *);
extern void execute_279(char*, char *);
extern void execute_394(char*, char *);
extern void execute_85(char*, char *);
extern void execute_86(char*, char *);
extern void execute_100(char*, char *);
extern void execute_101(char*, char *);
extern void execute_104(char*, char *);
extern void execute_105(char*, char *);
extern void execute_107(char*, char *);
extern void execute_108(char*, char *);
extern void execute_120(char*, char *);
extern void execute_121(char*, char *);
extern void execute_128(char*, char *);
extern void execute_129(char*, char *);
extern void execute_259(char*, char *);
extern void execute_260(char*, char *);
extern void execute_132(char*, char *);
extern void execute_133(char*, char *);
extern void execute_127(char*, char *);
extern void execute_262(char*, char *);
extern void execute_263(char*, char *);
extern void execute_271(char*, char *);
extern void execute_272(char*, char *);
extern void execute_281(char*, char *);
extern void execute_282(char*, char *);
extern void execute_283(char*, char *);
extern void execute_284(char*, char *);
extern void execute_285(char*, char *);
extern void execute_286(char*, char *);
extern void execute_296(char*, char *);
extern void execute_297(char*, char *);
extern void execute_303(char*, char *);
extern void execute_306(char*, char *);
extern void execute_307(char*, char *);
extern void execute_308(char*, char *);
extern void execute_309(char*, char *);
extern void execute_310(char*, char *);
extern void execute_288(char*, char *);
extern void execute_289(char*, char *);
extern void execute_291(char*, char *);
extern void execute_293(char*, char *);
extern void execute_299(char*, char *);
extern void execute_301(char*, char *);
extern void execute_302(char*, char *);
extern void execute_305(char*, char *);
extern void execute_318(char*, char *);
extern void execute_319(char*, char *);
extern void execute_327(char*, char *);
extern void execute_328(char*, char *);
extern void execute_330(char*, char *);
extern void execute_331(char*, char *);
extern void execute_333(char*, char *);
extern void execute_334(char*, char *);
extern void execute_342(char*, char *);
extern void execute_343(char*, char *);
extern void execute_381(char*, char *);
extern void transaction_0(char*, char*, unsigned, unsigned, unsigned);
extern void vhdl_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
extern void transaction_167(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_173(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_180(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_181(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[69] = {(funcp)execute_64, (funcp)execute_395, (funcp)execute_82, (funcp)execute_83, (funcp)execute_90, (funcp)execute_102, (funcp)execute_109, (funcp)execute_279, (funcp)execute_394, (funcp)execute_85, (funcp)execute_86, (funcp)execute_100, (funcp)execute_101, (funcp)execute_104, (funcp)execute_105, (funcp)execute_107, (funcp)execute_108, (funcp)execute_120, (funcp)execute_121, (funcp)execute_128, (funcp)execute_129, (funcp)execute_259, (funcp)execute_260, (funcp)execute_132, (funcp)execute_133, (funcp)execute_127, (funcp)execute_262, (funcp)execute_263, (funcp)execute_271, (funcp)execute_272, (funcp)execute_281, (funcp)execute_282, (funcp)execute_283, (funcp)execute_284, (funcp)execute_285, (funcp)execute_286, (funcp)execute_296, (funcp)execute_297, (funcp)execute_303, (funcp)execute_306, (funcp)execute_307, (funcp)execute_308, (funcp)execute_309, (funcp)execute_310, (funcp)execute_288, (funcp)execute_289, (funcp)execute_291, (funcp)execute_293, (funcp)execute_299, (funcp)execute_301, (funcp)execute_302, (funcp)execute_305, (funcp)execute_318, (funcp)execute_319, (funcp)execute_327, (funcp)execute_328, (funcp)execute_330, (funcp)execute_331, (funcp)execute_333, (funcp)execute_334, (funcp)execute_342, (funcp)execute_343, (funcp)execute_381, (funcp)transaction_0, (funcp)vhdl_transfunc_eventcallback, (funcp)transaction_167, (funcp)transaction_173, (funcp)transaction_180, (funcp)transaction_181};
const int NumRelocateId= 69;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/TB_behav/xsim.reloc",  (void **)funcTab, 69);
	iki_vhdl_file_variable_register(dp + 160328);
	iki_vhdl_file_variable_register(dp + 160384);


	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/TB_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/TB_behav/xsim.reloc");

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
