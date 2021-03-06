% Obsolete as of 2014-01-05

function num_net = cnnnumgradcheck_siamese(net, x1, x2, y, L_funvL)
    epsilon = 1e-4;
    er      = 1e-8;
    n = numel(net.layers);
    num_net = net;
    num_net.dffb = nan(size(net.ffb));
    
    numProgressSteps = 11;
    
    fprintf('   numgrad: ffb\n')
    for j = 1 : numel(net.ffb)
        net_m = net; net_p = net;
        net_p.ffb(j) = net_m.ffb(j) + epsilon;
        net_m.ffb(j) = net_m.ffb(j) - epsilon;
        
        net_m = cnnff(net_m, x1); %net_m = cnnbp(net_m, y);
        net_m_o1 = net_m.o;
        net_p = cnnff(net_p, x1); %net_p = cnnbp(net_p, y);
        net_p_o1 = net_p.o;
        
        net_m = cnnff(net_m, x2); %net_m = cnnbp(net_m, y);
        net_m_o2 = net_m.o;
        net_p = cnnff(net_p, x2); %net_p = cnnbp(net_p, y);
        net_p_o2 = net_p.o;
        
        net_m.L = L_funvL(net_m_o1', net_m_o2', y);
        net_p.L = L_funvL(net_p_o1', net_p_o2', y);
        
        d = mean((net_p.L - net_m.L) / (2 * epsilon));
        %e = abs(d - net.dffb(j));
        num_net.dffb(j) = d;
        %{
        if e > er
            e
            d / net.dffb(j)
            error('ffb numerical gradient checking failed');
        end
        %}
    end
    
    fprintf('   numgrad: ffW\n')
    
    for i = 1 : size(net.ffW, 1)
        for u = 1 : size(net.ffW, 2)
            net_m = net; net_p = net;
            net_p.ffW(i, u) = net_m.ffW(i, u) + epsilon;
            net_m.ffW(i, u) = net_m.ffW(i, u) - epsilon;
            %net_m = cnnff(net_m, x); net_m = cnnbp(net_m, y);
            %net_p = cnnff(net_p, x); net_p = cnnbp(net_p, y);
            
            net_m = cnnff(net_m, x1); %net_m = cnnbp(net_m, y);
            net_m_o1 = net_m.o;
            net_p = cnnff(net_p, x1); %net_p = cnnbp(net_p, y);
            net_p_o1 = net_p.o;

            net_m = cnnff(net_m, x2); %net_m = cnnbp(net_m, y);
            net_m_o2 = net_m.o;
            net_p = cnnff(net_p, x2); %net_p = cnnbp(net_p, y);
            net_p_o2 = net_p.o;
            
            net_m.L = L_funvL(net_m_o1', net_m_o2', y);
            net_p.L = L_funvL(net_p_o1', net_p_o2', y);
            
            d = mean((net_p.L - net_m.L) / (2 * epsilon));
            %e = abs(d - net.dffW(i, u));
            num_net.dffW(i, u) = d;
            %{
            if e > er
                e
                d / net.ffW(i, u)
                error('ffW numerical gradient checking failed');
            end
            %}
        end
    end

    fprintf('   numgrad: layers\n')
    
    for l = n : -1 : 2
        if strcmp(net.layers{l}.type, 'c')
            for j = 1 : numel(net.layers{l}.a)
                net_m = net; net_p = net;
                net_p.layers{l}.b{j} = net_m.layers{l}.b{j} + epsilon;
                net_m.layers{l}.b{j} = net_m.layers{l}.b{j} - epsilon;
                %net_m = cnnff(net_m, x); net_m = cnnbp(net_m, y);
                %net_p = cnnff(net_p, x); net_p = cnnbp(net_p, y);

                net_m = cnnff(net_m, x1); %net_m = cnnbp(net_m, y);
                net_m_o1 = net_m.o;
                net_p = cnnff(net_p, x1); %net_p = cnnbp(net_p, y);
                net_p_o1 = net_p.o;

                net_m = cnnff(net_m, x2); %net_m = cnnbp(net_m, y);
                net_m_o2 = net_m.o;
                net_p = cnnff(net_p, x2); %net_p = cnnbp(net_p, y);
                net_p_o2 = net_p.o;

                net_m.L = L_funvL(net_m_o1', net_m_o2', y);
                net_p.L = L_funvL(net_p_o1', net_p_o2', y);                
                
                d = mean((net_p.L - net_m.L) / (2 * epsilon));
                %e = abs(d - net.layers{l}.db{j});
                num_net.layers{l}.db{j} = d;
                %{
                if e > er
                    e
                    d / net.layers{l}.db{j}
                    error('db numerical gradient checking failed');
                end
                %}
                for i = 1 : numel(net.layers{l - 1}.a)
                    for u = 1 : size(net.layers{l}.k{i}{j}, 1)
                        for v = 1 : size(net.layers{l}.k{i}{j}, 2)
                            net_m = net; net_p = net;
                            net_p.layers{l}.k{i}{j}(u, v) = net_p.layers{l}.k{i}{j}(u, v) + epsilon;
                            net_m.layers{l}.k{i}{j}(u, v) = net_m.layers{l}.k{i}{j}(u, v) - epsilon;
                            %net_m = cnnff(net_m, x); net_m = cnnbp(net_m, y);
                            %net_p = cnnff(net_p, x); net_p = cnnbp(net_p, y);
                            
                            net_m = cnnff(net_m, x1); %net_m = cnnbp(net_m, y);
                            net_m_o1 = net_m.o;
                            net_p = cnnff(net_p, x1); %net_p = cnnbp(net_p, y);
                            net_p_o1 = net_p.o;

                            net_m = cnnff(net_m, x2); %net_m = cnnbp(net_m, y);
                            net_m_o2 = net_m.o;
                            net_p = cnnff(net_p, x2); %net_p = cnnbp(net_p, y);
                            net_p_o2 = net_p.o;

                            net_m.L = L_funvL(net_m_o1', net_m_o2', y);
                            net_p.L = L_funvL(net_p_o1', net_p_o2', y);                            
                            
                            d = mean((net_p.L - net_m.L) / (2 * epsilon));
                            %e = abs(d - net.layers{l}.dk{i}{j}(u, v));
                            %{
                            if e > er
                                error('dk numerical gradient checking failed');
                            end
                            %}
                            num_net.layers{l}.dk{i}{j}(u, v) = d;
                        end
                    end
                end
            end
        elseif strcmp(net.layers{l}.type, 's')
%            for j = 1 : numel(net.layers{l}.a)
%                net_m = net; net_p = net;
%                net_p.layers{l}.b{j} = net_m.layers{l}.b{j} + epsilon;
%                net_m.layers{l}.b{j} = net_m.layers{l}.b{j} - epsilon;
%                net_m = cnnff(net_m, x); net_m = cnnbp(net_m, y);
%                net_p = cnnff(net_p, x); net_p = cnnbp(net_p, y);
%                d = (net_p.L - net_m.L) / (2 * epsilon);
%                e = abs(d - net.layers{l}.db{j});
%                if e > er
%                    error('numerical gradient checking failed');
%                end
%            end
        end
    end
%    keyboard
end