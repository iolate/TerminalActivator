#import <notify.h>

int main(int argc, char **argv, char **envp) {
    if (argc == 1)
    {
        printf("Usage: notify_post [noti name]\n");
        return 0;
    }
    
    notify_post(argv[1]);
    
	return 0;
}

// vim:ft=objc
