#pragma D option quiet

#define DOPRINT 0
#define ACTORMSG_BLOCK (4294967295 - 6)   // 4294967289
#define ACTORMSG_UNBLOCK (4294967295 - 5) // 4294967290
#define ACTORMSG_ACQUIRE (4294967295 - 4) // 4294967291
#define ACTORMSG_RELEASE (4294967295 - 3) // 4294967292
#define ACTORMSG_CONF (4294967295 - 2)  	// 4294967293
#define ACTORMSG_ACK (4294967295 - 1) 		// 4294967294

typedef struct pony_ctx_t
{
  struct scheduler_t* scheduler;
};

struct scheduler_t
{
  uint32_t tid;
  uint32_t cpu;
};

struct future_block {
  uint64_t start;
  uint64_t end;
};

struct future_fulfil {
  uint64_t start;
  uint64_t end;
};

struct future {
  uintptr_t ptr;
  uint64_t created;
  uint64_t lifetime;
  int get;
  int chaining;

  struct future_block blocking;
  struct future_fulfil fulfil;
};


// uint64_t future_created[uintptr_t];

struct future futures[uintptr_t];

pony$target:::actor-alloc {
	#if defined(DOPRINT) && DOPRINT > 0
    printf("Actor alloc on scheduler %d (cpu: %d)\n", arg0, cpu);
  #endif
}

pony$target:::actor-msg-send {
  @counter["Number of messages"] = count();
}

pony$target:::actor-msg-send /arg1 == ACTORMSG_BLOCK/ {
  #if defined(DOPRINT) && DOPRINT > 0
    printf("BLOCK msg sent on scheduler %d\n", arg0);
  #endif
}

pony$target:::actor-msg-send /arg1 == ACTORMSG_UNBLOCK/ {
    #if defined(DOPRINT) && DOPRINT > 0
      printf("UNBLOCK msg sent on scheduler %d\n", arg0);
    #endif
}

pony$target:::actor-msg-send /arg1 == ACTORMSG_ACQUIRE/ {
    #if defined(DOPRINT) && DOPRINT > 0
      printf("ACQUIRE msg sent on scheduler %d\n", arg0);
    #endif
}

pony$target:::actor-msg-send /arg1 == ACTORMSG_RELEASE/ {
    #if defined(DOPRINT) && DOPRINT > 0
      printf("RELEASE msg sent on scheduler %d\n", arg0);
    #endif
}

pony$target:::actor-msg-send /arg1 == ACTORMSG_CONF/ {
    #if defined(DOPRINT) && DOPRINT > 0
	   printf("CONF msg sent on scheduler %d\n", arg0);
     #endif
}

pony$target:::actor-msg-send /arg1 == ACTORMSG_ACK/ {
    #if defined(DOPRINT) && DOPRINT > 0
	   printf("ACK msg sent on scheduler %d\n", arg0);
  #endif
}

pony$target:::actor-msg-run /arg2 == ACTORMSG_BLOCK/ {
    #if defined(DOPRINT) && DOPRINT > 0
		  printf("Actor %d received BLOCK msg on scheduler %d\n", arg1, arg0);
    #endif
}

pony$target:::actor-msg-run /arg2 == ACTORMSG_UNBLOCK/ {
    #if defined(DOPRINT) && DOPRINT > 0
		  printf("Actor %d received UNBLOCK msg on scheduler %d\n", arg1, arg0);
    #endif
}

pony$target:::actor-msg-run /arg2 == ACTORMSG_ACQUIRE/ {
    #if defined(DOPRINT) && DOPRINT > 0
		  printf("Actor %d received ACQUIRE msg on scheduler %d\n", arg1, arg0);
    #endif
}

pony$target:::actor-msg-run /arg2 == ACTORMSG_RELEASE/ {
    #if defined(DOPRINT) && DOPRINT > 0
		  printf("Actor %d received RELEASE msg on scheduler %d\n", arg1, arg0);
    #endif
}

pony$target:::actor-msg-run /arg2 == ACTORMSG_CONF/ {
    #if defined(DOPRINT) && DOPRINT > 0
		  printf("Actor %d received CONF msg on scheduler %d\n", arg1, arg0);
    #endif
}

pony$target:::actor-msg-run /arg2 == ACTORMSG_ACK/ {
    #if defined(DOPRINT) && DOPRINT > 0
		  printf("Actor %d received ACK msg on scheduler %d\n", arg1, arg0);
    #endif
}

encore$target:::future-create {
  future_created[arg1] = timestamp;
  @counter[probename] = count();

  futures[arg1].created = timestamp;
  futures[arg1].ptr = arg1;
}

encore$target:::future-block {
  @counter[probename] = count();
  future_blocked[arg1] = timestamp;
  futures[arg1].blocking.start = timestamp;
}

encore$target:::future-unblock {
  @counter[probename] = count();
  @future_blocked_lifetime["Future blocked duration", arg1] = sum(timestamp - future_blocked[arg1]);
  futures[arg1].blocking.end = timestamp;
}

encore$target:::future-chaining {
  @counter[probename] = count();
  futures[arg1].chaining = 1;
}

encore$target:::future-fulfil-start {
  @counter[probename] = count();
  futures[arg1].fulfil.start = timestamp;
}

encore$target:::future-fulfil-end {
  @counter[probename] = count();
  futures[arg1].fulfil.end = timestamp;
}

encore$target:::future-get {
  @counter[probename] = count();
  futures[arg1].get = 1;
}

encore$target:::future-destroy {
  @counter[probename] = count();
  @future_lifetime["Future lifetime", arg1] = sum(timestamp - future_created[arg1]);
}

encore$target:::method-entry {
  // printf("\nMETHOD ENTRY: %s\n", copyinstr(arg2));
  // ctx = (struct pony_ctx_t *)copyin(arg0, sizeof(struct pony_ctx_t));
  // scd = (struct scheduler_t*)copyin((user_addr_t)ctx->scheduler, sizeof(struct scheduler_t));
  // print(*ctx);
  // print(*scd);
  // printf("\n");
}

BEGIN {

}

END {
}
