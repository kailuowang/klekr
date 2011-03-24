alias original_describe describe

def describe   *args, &block
    example = original_describe *args, &block
    klass = args[0]
    if klass.is_a? Class
        saved_private_instance_methods = klass.private_instance_methods
        example.before do
             klass.class_eval { public *saved_private_instance_methods }
        end
        example.after do
             klass.class_eval { private *saved_private_instance_methods }
        end
    end
end
