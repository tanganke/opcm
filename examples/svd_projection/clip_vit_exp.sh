# clip-vit-base-patch32
# eight tasks, ablation study on alpha
# without random seed, for each alpha, run 10 times
for alpha in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    for i in {0..9}; do
        if [ -f outputs/svd_projection/ablation-alpha/vit-b-32-TA8-alpha-${alpha}/version_${i}/report_7.json ]; then
            echo "skip alpha=${alpha}, version=${i}"
            continue
        fi
        fusion_bench \
            fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
            fabric.loggers.name=vit-b-32-TA8-alpha-${alpha} \
            fabric.loggers.version=${i} \
            method=svd_projection/sequential_projection \
            method.alpha=$alpha \
            method.seed=null \
            method.save_on_every_step=false \
            modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TA8_model_only \
            taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TA8
    done
done

# clip-vit-large-patch14
# eight tasks, ablation study on alpha
# without random seed, for each alpha, run 10 times
for alpha in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    for i in {0..9}; do
        if [ -f outputs/svd_projection/ablation-alpha/vit-l-14-TA8-alpha-${alpha}/version_${i}/report_7.json ]; then
            echo "skip alpha=${alpha}, version=${i}"
            continue
        fi
        fusion_bench \
            fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
            fabric.loggers.name=vit-l-14-TA8-alpha-${alpha} \
            fabric.loggers.version=${i} \
            method=svd_projection/sequential_projection \
            method.alpha=$alpha \
            method.seed=null \
            method.save_on_every_step=false \
            modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TA8_model_only \
            taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TA8_L14
    done
done

# clip-vit-base-patch16
# eight tasks, alpha = 0.5
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-b-16-TA8-alpha-0.5/version_${i}/report_7.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-b-16-TA8-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TA8_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TA8_B16
done

# clip-vit-base-patch32, 14 tasks
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-b-32-TALL14-alpha-0.5/version_${i}/report_13.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-b-32-TALL14-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14
done

# clip-vit-base-patch16, 14 tasks
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-b-16-TALL14-alpha-0.5/version_${i}/report_13.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-b-16-TALL14-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14 \
        taskpool.base_model=openai/clip-vit-base-patch16
done

# clip-vit-large-patch14, 14 tasks
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-l-14-TALL14-alpha-0.5/version_${i}/report_13.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-l-14-TALL14-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14 \
        taskpool.base_model=openai/clip-vit-large-patch14
done

# clip-vit-base-patch32, 20 tasks
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-b-32-TALL20-alpha-0.5/version_${i}/report_19.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-b-32-TALL20-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20
done

# clip-vit-base-patch16, 20 tasks
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-b-16-TALL20-alpha-0.5/version_${i}/report_19.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-b-16-TALL20-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20 \
        taskpool.base_model=openai/clip-vit-base-patch16
done

# clip-vit-large-patch14, 20 tasks
# without random seed, for alpha=0.5, run 10 times
for i in {0..9}; do
    if [ -f outputs/svd_projection/ablation-alpha/vit-l-14-TALL20-alpha-0.5/version_${i}/report_19.json ]; then
        echo "skip alpha=0.5, version=${i}"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/svd_projection/ablation-alpha \
        fabric.loggers.name=vit-l-14-TALL20-alpha-0.5 \
        fabric.loggers.version=${i} \
        method=svd_projection/sequential_projection \
        method.alpha=0.5 \
        method.seed=null \
        method.save_on_every_step=false \
        modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20 \
        taskpool.base_model=openai/clip-vit-large-patch14
done

# === Task Arithmetic ===
# vit-b-32, 14 tasks
for scaling_factor in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ -f outputs/task_arithmetic/vit-b-32-TALL14-scaling-factor-${scaling_factor}/version_0/report.json ]; then
        echo "skip scaling_factor=${scaling_factor}, version=0"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/task_arithmetic \
        fabric.loggers.name=vit-b-32-TALL14-scaling-factor-${scaling_factor} \
        fabric.loggers.version=0 \
        method=task_arithmetic \
        method.scaling_factor=${scaling_factor} \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14
done

# vit-b-16, 14 tasks
for scaling_factor in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ -f outputs/task_arithmetic/vit-b-16-TALL14-scaling-factor-${scaling_factor}/version_0/report.json ]; then
        echo "skip scaling_factor=${scaling_factor}, version=0"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/task_arithmetic \
        fabric.loggers.name=vit-b-16-TALL14-scaling-factor-${scaling_factor} \
        fabric.loggers.version=0 \
        method=task_arithmetic \
        method.scaling_factor=${scaling_factor} \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14 \
        taskpool.base_model=openai/clip-vit-base-patch16
done

# vit-l-14, 14 tasks
for scaling_factor in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ -f outputs/task_arithmetic/vit-l-14-TALL14-scaling-factor-${scaling_factor}/version_0/report.json ]; then
        echo "skip scaling_factor=${scaling_factor}, version=0"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/task_arithmetic \
        fabric.loggers.name=vit-l-14-TALL14-scaling-factor-${scaling_factor} \
        fabric.loggers.version=0 \
        method=task_arithmetic \
        method.scaling_factor=${scaling_factor} \
        modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14 \
        taskpool.base_model=openai/clip-vit-large-patch14
done

# vit-b-32, 20 tasks
for scaling_factor in 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ -f outputs/task_arithmetic/vit-b-32-TALL20-scaling-factor-${scaling_factor}/version_0/report.json ]; then
        echo "skip scaling_factor=${scaling_factor}, version=0"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/task_arithmetic \
        fabric.loggers.name=vit-b-32-TALL20-scaling-factor-${scaling_factor} \
        fabric.loggers.version=0 \
        method=task_arithmetic \
        method.scaling_factor=${scaling_factor} \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20
done

# vit-b-16, 20 tasks
for scaling_factor in 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ -f outputs/task_arithmetic/vit-b-16-TALL20-scaling-factor-${scaling_factor}/version_0/report.json ]; then
        echo "skip scaling_factor=${scaling_factor}, version=0"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/task_arithmetic \
        fabric.loggers.name=vit-b-16-TALL20-scaling-factor-${scaling_factor} \
        fabric.loggers.version=0 \
        method=task_arithmetic \
        method.scaling_factor=${scaling_factor} \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20 \
        taskpool.base_model=openai/clip-vit-base-patch16
done

# vit-l-14, 20 tasks
for scaling_factor in 0.05 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0; do
    if [ -f outputs/task_arithmetic/vit-l-14-TALL20-scaling-factor-${scaling_factor}/version_0/report.json ]; then
        echo "skip scaling_factor=${scaling_factor}, version=0"
        continue
    fi
    fusion_bench \
        fabric.loggers.root_dir=outputs/task_arithmetic \
        fabric.loggers.name=vit-l-14-TALL20-scaling-factor-${scaling_factor} \
        fabric.loggers.version=0 \
        method=task_arithmetic \
        method.scaling_factor=${scaling_factor} \
        modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20 \
        taskpool.base_model=openai/clip-vit-large-patch14
done

# === Simple Average ===
# clip-vit-base-patch32, 14 tasks
if [ ! -f outputs/simple_average/vit-b-32-TALL14/version_0/report.json ]; then
    fusion_bench \
        fabric.loggers.root_dir=outputs/simple_average \
        fabric.loggers.name=vit-b-32-TALL14 \
        fabric.loggers.version=0 \
        method=simple_average \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14
fi

# clip-vit-base-patch16, 14 tasks
if [ ! -f outputs/simple_average/vit-b-16-TALL14/version_0/report.json ]; then
    fusion_bench \
        fabric.loggers.root_dir=outputs/simple_average \
        fabric.loggers.name=vit-b-16-TALL14 \
        fabric.loggers.version=0 \
        method=simple_average \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14 \
        taskpool.base_model=openai/clip-vit-base-patch16
fi

# clip-vit-large-patch14, 14 tasks
if [ ! -f outputs/simple_average/vit-l-14-TALL14/version_0/report.json ]; then
    fusion_bench \
        fabric.loggers.root_dir=outputs/simple_average \
        fabric.loggers.name=vit-l-14-TALL14 \
        fabric.loggers.version=0 \
        method=simple_average \
        modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TALL14_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL14 \
        taskpool.base_model=openai/clip-vit-large-patch14
fi

# clip-vit-base-patch32, 20 tasks
if [ ! -f outputs/simple_average/vit-b-32-TALL20/version_0/report.json ]; then
    fusion_bench \
        fabric.loggers.root_dir=outputs/simple_average \
        fabric.loggers.name=vit-b-32-TALL20 \
        fabric.loggers.version=0 \
        method=simple_average \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch32_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20
fi

# clip-vit-base-patch16, 20 tasks
if [ ! -f outputs/simple_average/vit-b-16-TALL20/version_0/report.json ]; then
    fusion_bench \
        fabric.loggers.root_dir=outputs/simple_average \
        fabric.loggers.name=vit-b-16-TALL20 \
        fabric.loggers.version=0 \
        method=simple_average \
        modelpool=CLIPVisionModelPool/clip-vit-base-patch16_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20 \
        taskpool.base_model=openai/clip-vit-base-patch16
fi

# clip-vit-large-patch14, 20 tasks
if [ ! -f outputs/simple_average/vit-l-14-TALL20/version_0/report.json ]; then
    fusion_bench \
        fabric.loggers.root_dir=outputs/simple_average \
        fabric.loggers.name=vit-l-14-TALL20 \
        fabric.loggers.version=0 \
        method=simple_average \
        modelpool=CLIPVisionModelPool/clip-vit-large-patch14_TALL20_model_only \
        taskpool=CLIPVisionModelTaskPool/clip-vit-classification_TALL20 \
        taskpool.base_model=openai/clip-vit-large-patch14
fi
