//
//  main.cpp
//  test_real_puls
//
//  Created by Philipp Adis on 14.06.16.
//  Copyright © 2016 Philipp Adis. All rights reserved.
//

#include <iostream>

int main(int argc, const char * argv[]) {
    // insert code here...
    double zi[4] = {-0.9441,2.8324,-2.8324,0.9441};
    double b[5] = {0.9441,-3.7766,5.6649,-3.7766,0.9441};
    double a[5] = {1,-3.8851, 5.6618, 3.6681, 0.8914};
    double y[324];
    double x[324] = {-0.808685302734375 ,
        -0.820892333984375 ,
        -0.811431884765625 ,
        -0.758468627929688 ,
        -0.7330322265625 ,
        -0.720672607421875 ,
        -0.711517333984375 ,
        -0.655792236328125 ,
        -0.612289428710938 ,
        -0.606399536132812 ,
        -0.597381591796875 ,
        -0.67010498046875 ,
        -0.776107788085938 ,
        -0.882110595703125 ,
        -0.954833984375 ,
        -0.945816040039062 ,
        -0.939926147460938 ,
        -0.89642333984375 ,
        -0.8406982421875 ,
        -0.83154296875 ,
        -0.819183349609375 ,
        -0.793746948242188 ,
        -0.74078369140625 ,
        -0.7313232421875 ,
        -0.7435302734375 ,
        -0.771316528320312 ,
        -0.874191284179688 ,
        -0.530746459960938 ,
        -0.285736083984375 ,
        -0.123291015625 ,
        0.0266876220703125 ,
        0.14862060546875 ,
        0.302749633789062 ,
        0.432052612304688 ,
        0.464462280273438 ,
        0.21734619140625 ,
        -0.185104370117188 ,
        -0.616973876953125 ,
        -1.09951782226562 ,
        -1.47383117675781 ,
        -1.65731811523438 ,
        -1.70121765136719 ,
        -1.64726257324219 ,
        -1.5089111328125 ,
        -1.28250122070312 ,
        -1.07394409179688 ,
        -0.9371337890625 ,
        -0.766098022460938 ,
        -0.586868286132812 ,
        -0.33575439453125 ,
        -0.0389556884765625 ,
        0.241165161132812 ,
        0.427352905273438 ,
        0.567916870117188 ,
        0.728591918945312 ,
        0.659423828125 ,
        0.388031005859375 ,
        -0.114532470703125 ,
        -0.750442504882812 ,
        -1.37600708007812 ,
        -1.70643615722656 ,
        -1.68014526367188 ,
        -1.51603698730469 ,
        -1.34745788574219 ,
        -1.04763793945312 ,
        -0.717239379882812 ,
        -0.300735473632812 ,
        -0.03277587890625 ,
        0.391143798828125 ,
        0.767166137695312 ,
        1.01522827148438 ,
        1.02717590332031 ,
        0.83770751953125 ,
        0.354965209960938 ,
        -0.230178833007812 ,
        -1.01493835449219 ,
        -1.96479797363281 ,
        -2.41120910644531 ,
        -2.2354736328125 ,
        -1.74851989746094 ,
        -1.31036376953125 ,
        -0.921142578125 ,
        -0.470306396484375 ,
        -0.105743408203125 ,
        0.11785888671875 ,
        0.330291748046875 ,
        0.655563354492188 ,
        0.9840087890625 ,
        1.14749145507812 ,
        1.14222717285156 ,
        0.750839233398438 ,
        -0.0956573486328125 ,
        -1.03858947753906 ,
        -1.67631530761719 ,
        -2.16732788085938 ,
        -2.37477111816406 ,
        -1.99058532714844 ,
        -1.06428527832031 ,
        -0.287429809570312 ,
        0.07684326171875 ,
        0.118057250976562 ,
        0.324066162109375 ,
        0.538070678710938 ,
        0.459915161132812 ,
        0.3951416015625 ,
        0.4605712890625 ,
        0.09881591796875 ,
        -0.444686889648438 ,
        -0.958786010742188 ,
        -1.29043579101562 ,
        -1.47627258300781 ,
        -1.56446838378906 ,
        -1.51087951660156 ,
        -1.23472595214844 ,
        -0.8323974609375 ,
        -0.385467529296875 ,
        0.084869384765625 ,
        0.525588989257812 ,
        0.876876831054688 ,
        0.981582641601562 ,
        0.911605834960938 ,
        0.736572265625 ,
        0.375900268554688 ,
        -0.2447509765625 ,
        -0.758148193359375 ,
        -1.08903503417969 ,
        -1.250732421875 ,
        -1.23703002929688 ,
        -1.20993041992188 ,
        -1.24470520019531 ,
        -1.20138549804688 ,
        -0.979507446289062 ,
        -0.647445678710938 ,
        -0.183486938476562 ,
        0.214019775390625 ,
        0.64276123046875 ,
        0.831466674804688 ,
        0.147705078125 ,
        -0.0543060302734375 ,
        0.0997467041015625 ,
        -0.0840301513671875 ,
        -0.813278198242188 ,
        -1.74041748046875 ,
        -2.06391906738281 ,
        -1.51788330078125 ,
        -1.32804870605469 ,
        -1.19673156738281 ,
        -1.13861083984375 ,
        -1.14601135253906 ,
        -1.19131469726562 ,
        -0.995529174804688 ,
        -0.517501831054688 ,
        -0.41644287109375 ,
        -0.135711669921875 ,
        0.756988525390625 ,
        1.12367248535156 ,
        1.32853698730469 ,
        1.31343078613281 ,
        1.01747131347656 ,
        0.66033935546875 ,
        0.141265869140625 ,
        -0.617965698242188 ,
        -1.40058898925781 ,
        -2.00784301757812 ,
        -2.42060852050781 ,
        -2.52424621582031 ,
        -2.22586059570312 ,
        -1.64508056640625 ,
        -1.05903625488281 ,
        -0.512619018554688 ,
        0.046783447265625 ,
        0.463287353515625 ,
        0.767425537109375 ,
        1.05680847167969 ,
        1.3782958984375 ,
        1.60371398925781 ,
        1.56948852539062 ,
        1.05271911621094 ,
        0.0030364990234375 ,
        -1.32539367675781 ,
        -2.437744140625 ,
        -3.15585327148438 ,
        -3.23486328125 ,
        -2.68161010742188 ,
        -1.94857788085938 ,
        -1.30047607421875 ,
        -0.802078247070312 ,
        -0.3726806640625 ,
        0.031463623046875 ,
        0.400558471679688 ,
        0.809844970703125 ,
        1.12861633300781 ,
        1.43989562988281 ,
        1.60067749023438 ,
        1.508056640625 ,
        1.17753601074219 ,
        0.444183349609375 ,
        -0.495941162109375 ,
        -1.38252258300781 ,
        -2.21249389648438 ,
        -2.85038757324219 ,
        -2.8980712890625 ,
        -1.74201965332031 ,
        -1.26152038574219 ,
        -0.915557861328125 ,
        -0.628265380859375 ,
        -0.40130615234375 ,
        -0.235382080078125 ,
        -0.0726776123046875 ,
        0.1568603515625 ,
        0.493011474609375 ,
        0.836456298828125 ,
        1.14317321777344 ,
        1.23846435546875 ,
        0.958663940429688 ,
        0.266372680664062 ,
        -0.700698852539062 ,
        -1.61351013183594 ,
        -2.45881652832031 ,
        -2.98927307128906 ,
        -2.77091979980469 ,
        -2.15252685546875 ,
        -1.58151245117188 ,
        -1.17361450195312 ,
        -0.8909912109375 ,
        -0.610641479492188 ,
        -0.34417724609375 ,
        -0.01763916015625 ,
        0.292465209960938 ,
        0.578201293945312 ,
        0.874832153320312 ,
        1.08184814453125 ,
        1.07098388671875 ,
        0.679336547851562 ,
        -0.0069427490234375 ,
        -0.685821533203125 ,
        -1.36097717285156 ,
        -1.92802429199219 ,
        -2.33488464355469 ,
        -2.40097045898438 ,
        -2.0985107421875 ,
        -1.65103149414062 ,
        -1.20259094238281 ,
        -0.7872314453125 ,
        -0.417694091796875 ,
        -0.0486297607421875 ,
        0.257461547851562 ,
        0.503692626953125 ,
        0.79010009765625 ,
        1.03553771972656 ,
        1.18202209472656 ,
        0.924331665039062 ,
        0.344711303710938 ,
        -0.375137329101562 ,
        -1.1387939453125 ,
        -1.97557067871094 ,
        -2.69548034667969 ,
        -2.96908569335938 ,
        -2.66500854492188 ,
        -2.00607299804688 ,
        -1.3741455078125 ,
        -0.893417358398438 ,
        -0.536361694335938 ,
        -0.226364135742188 ,
        0.0511322021484375 ,
        0.286361694335938 ,
        0.562286376953125 ,
        0.844573974609375 ,
        1.04866027832031 ,
        1.15679931640625 ,
        0.99615478515625 ,
        0.48370361328125 ,
        -0.135772705078125 ,
        -0.824935913085938 ,
        -1.6771240234375 ,
        -2.315673828125 ,
        -2.607421875 ,
        -2.43960571289062 ,
        -1.96441650390625 ,
        -1.55186462402344 ,
        -1.20684814453125 ,
        -0.883514404296875 ,
        -0.543106079101562 ,
        -0.2227783203125 ,
        0.017913818359375 ,
        0.246963500976562 ,
        0.460769653320312 ,
        0.662078857421875 ,
        0.8358154296875 ,
        0.835525512695312 ,
        0.660568237304688 ,
        0.286209106445312 ,
        -0.278945922851562 ,
        -0.901626586914062 ,
        -1.64370727539062 ,
        -2.2598876953125 ,
        -2.55441284179688 ,
        -2.57534790039062 ,
        -1.58401489257812 ,
        -1.01170349121094 ,
        -0.531845092773438 ,
        -0.101837158203125 ,
        0.223846435546875 ,
        0.410980224609375 ,
        0.65704345703125 ,
        0.784194946289062 ,
        0.860336303710938 ,
        0.925064086914062 ,
        0.704559326171875 ,
        0.245254516601562 ,
        -0.359054565429688 ,
        -1.08792114257812 ,
        -1.81678771972656 ,
        -2.42109680175781 ,
        -2.88040161132812 ,
        -3.10090637207031 ,
        -3.03617858886719 ,
        -2.96003723144531 ,
        -2.8328857421875 ,
        -2.58682250976562 ,
        -2.39968872070312 ,
        -2.07400512695312 ,
        -1.64399719238281 ,
        -1.16413879394531};
    
    
    double dbuffer[5];
    
    int k;
    int j;
    for (k = 0; k < 4; k++) {
        dbuffer[k + 1] = zi[k];
    }
    
    for (j = 0; j < 324; j++) {
        for (k = 0; k < 4; k++) {
            dbuffer[k] = dbuffer[k + 1];
        }
        
        dbuffer[4] = 0.0;
            for (k = 0; k < 5; k++) {
                dbuffer[k] += x[j] * b[k];
            }
            
            for (k = 0; k < 4; k++) {
                dbuffer[k + 1] -= dbuffer[0] * a[k + 1];
            }
            
            y[j] = dbuffer[0];
        }
    
    for (k = 0; k < 324; k++)
    {
        std::cout << y[k] <<"\n";
    }
    return 0;
}
