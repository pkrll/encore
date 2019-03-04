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

struct future futures[uintptr_t];

int number_of_messages_sent;
int number_of_futures;

pony$target:::actor-alloc {
	#if defined(DOPRINT) && DOPRINT == 1
    printf("Actor alloc on scheduler %d (cpu: %d)\n", arg0, cpu);
  #endif
}

pony$target:::actor-msg-send {
  @[probename] = count();
  number_of_messages_sent += 1;
}

encore$target:::future-create {
  number_of_futures += 1;
  future_created[arg1] = timestamp;
  @counter[probename] = count();
}

encore$target:::future-block {
  @counter[probename] = count();
  future_blocked[arg1] = timestamp;
}

encore$target:::future-unblock {
  @counter[probename] = count();
  @future_blocked_lifetime["Future blocked duration", arg1] = sum(timestamp - future_blocked[arg1]);
}

encore$target:::future-chaining {
  @counter[probename] = count();
}

encore$target:::future-fulfil-start {
  @counter[probename] = count();
}

encore$target:::future-fulfil-end {
  @counter[probename] = count();
}

encore$target:::future-get {
  @counter[probename] = count();
}

encore$target:::future-destroy {
  @counter[probename] = count();
  @future_lifetime["Future lifetime", arg1] = sum(timestamp - future_created[arg1]);
}

encore$target:::method-entry {
  // printf("\nMETHOD ENTRY: %s (%d)\n", copyinstr(arg2), arg2);
  // ctx = (struct pony_ctx_t *)copyin(arg0, sizeof(struct pony_ctx_t));
  // scd = (struct scheduler_t*)copyin((user_addr_t)ctx->scheduler, sizeof(struct scheduler_t));
  // print(*ctx);
  // print(*scd);
  // printf("\n");
}

END {
  ratio = (number_of_futures > 0) ? number_of_messages_sent / number_of_futures : 0;
  printf("Ratio: %d\n", ratio);
}
